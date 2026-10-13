#!/bin/bash

# usage: microbiome-collection/SCRIPTS/rerun_all.sh [--dry-run] [--yes] [STEP ...] (run from cmc/)

# reruns cmc.sh on every batch that has already been processed
# a batch is CMC_DB/<batch>/ with a matching manifest at MANIFESTS/<batch>
# STEP names are output directories (e.g. GENOMAD PROKKA) that are deleted in every batch before rerunning
# steps that use the output of a named step are deleted too, and DB/ is rebuilt whenever any step is run
# with no STEP names, only steps whose output directories are missing are run
# --dry-run prints what would be done without deleting or running anything
# --yes skips the confirmation prompt (e.g. when running with nohup)

# directory containing cmc.sh
PIPELINE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"

# output directories in the order cmc.sh runs them
STEPS=(FASTP SHOVILL CHECKM GTDBTK ABRITAMR GENOMAD PROKKA EMAPPER ANTISMASH DB)

# steps that use the output of each step
downstream() {
    case "$1" in
        FASTP)   echo "SHOVILL CHECKM GTDBTK ABRITAMR GENOMAD PROKKA EMAPPER ANTISMASH" ;;
        SHOVILL) echo "CHECKM GTDBTK ABRITAMR GENOMAD PROKKA EMAPPER ANTISMASH" ;;
        PROKKA)  echo "EMAPPER ANTISMASH" ;;
    esac
}

# returns 0 if the first argument is one of the remaining arguments
contains() {
    local item=$1 ; shift
    for x in "$@" ; do [ "$x" == "$item" ] && return 0 ; done
    return 1
}

# must be run from the cmc/ directory containing CMC_DB/ and MANIFESTS/
if [ ! -d CMC_DB/ ] || [ ! -d MANIFESTS/ ] ; then
    echo "ERROR: CMC_DB/ and MANIFESTS/ not found - run this script from the cmc/ directory"
    exit 1
fi

# read options and step names
DRYRUN="false"
YES="false"
REQUESTED=()

for arg in "$@" ; do

    case "$arg" in
        --dry-run) DRYRUN="true" ;;
        --yes)     YES="true" ;;
        *)
            step=$(echo "${arg%/}" | tr '[:lower:]' '[:upper:]')
            if ! contains "$step" "${STEPS[@]}" ; then
                echo "ERROR: unknown step '${arg}' - valid steps are: ${STEPS[*]}"
                exit 1
            fi
            REQUESTED+=("$step" $(downstream "$step"))
            ;;
    esac

done

# steps to delete and rerun in every batch, in pipeline order
REDO=()
for step in "${STEPS[@]}" ; do
    if contains "$step" "${REQUESTED[@]}" ; then REDO+=("$step") ; fi
done

if [ ${#REDO[@]} -gt 0 ] ; then
    echo "Steps to rerun in every batch: ${REDO[*]}"
else
    echo "No steps named - only running steps with missing output directories"
fi
echo

# batches that have been processed and have a manifest
BATCHES=()
NO_MANIFEST=()

for dir in CMC_DB/*/ ; do

    [ -d "$dir" ] || continue
    batch=$(basename "$dir")

    if [ -f MANIFESTS/"$batch" ] ; then
        BATCHES+=("$batch")
    else
        NO_MANIFEST+=("$batch")
    fi

done

# manifests for batches that have not been processed yet
NEW=()
for manifest in MANIFESTS/* ; do

    [ -f "$manifest" ] || continue
    batch=$(basename "$manifest")
    [ -d CMC_DB/"$batch" ] || NEW+=("$batch")

done

if [ ${#NO_MANIFEST[@]} -gt 0 ] ; then
    echo "Skipping batches with no manifest in MANIFESTS/: ${NO_MANIFEST[*]}"
fi

if [ ${#NEW[@]} -gt 0 ] ; then
    echo "Skipping manifests with no output in CMC_DB/ (not yet processed): ${NEW[*]}"
fi

# work out what to delete and run in each batch
PLAN_BATCHES=()
PLAN_DELETE=()
PLAN_RUN=()

echo
echo "Plan:"

for batch in "${BATCHES[@]}" ; do

    delete=()
    run=()

    for step in "${STEPS[@]}" ; do

        [ "$step" == "DB" ] && continue

        if contains "$step" "${REDO[@]}" ; then
            [ -d CMC_DB/"$batch"/"$step" ] && delete+=("$step")
            run+=("$step")
        elif [ ! -d CMC_DB/"$batch"/"$step" ] ; then
            run+=("$step")
        fi

    done

    # rebuild the database tables if anything else is run
    if [ ${#run[@]} -gt 0 ] || contains "DB" "${REDO[@]}" || [ ! -d CMC_DB/"$batch"/DB ] ; then
        [ -d CMC_DB/"$batch"/DB ] && delete+=("DB")
        run+=("DB")
    fi

    if [ ${#run[@]} -eq 0 ] ; then
        echo "  ${batch}: up to date - skipped"
        continue
    fi

    echo "  ${batch}"
    echo "      delete: ${delete[*]:--}"
    echo "      run:    ${run[*]}"

    PLAN_BATCHES+=("$batch")
    PLAN_DELETE+=("${delete[*]}")
    PLAN_RUN+=("${run[*]}")

done

echo

if [ ${#PLAN_BATCHES[@]} -eq 0 ] ; then
    echo "Nothing to do"
    exit 0
fi

if [ "$DRYRUN" == "true" ] ; then
    echo "Dry run - nothing deleted or run"
    exit 0
fi

if [ "$YES" != "true" ] ; then

    read -r -p "Proceed? [y/N] " answer
    if [[ ! "$answer" =~ ^[Yy]$ ]] ; then
        echo "Aborted - nothing deleted or run"
        exit 0
    fi

fi

# run each batch in turn, continuing if one fails
RESULTS=()
FAILED="false"

for n in "${!PLAN_BATCHES[@]}" ; do

    batch=${PLAN_BATCHES[$n]}
    log=CMC_DB/"$batch"/rerun_$(date +%Y%m%d_%H%M%S).log

    echo "$(date '+%F %T') ${batch}: started (log: ${log})"

    for step in ${PLAN_DELETE[$n]} ; do
        rm -rf -- CMC_DB/"${batch:?}"/"${step:?}"
    done

    "$PIPELINE_DIR"/cmc.sh MANIFESTS/"$batch" CMC_DB/"$batch"/ > "$log" 2>&1
    status=$?

    # cmc.sh does not stop when a step fails, so also check every step produced its output directory
    missing=()
    for step in ${PLAN_RUN[$n]} ; do
        [ -d CMC_DB/"$batch"/"$step" ] || missing+=("$step")
    done

    if [ "$status" -ne 0 ] || [ ${#missing[@]} -gt 0 ] ; then
        result="FAILED (exit ${status}${missing[*]:+, missing: ${missing[*]}}) - see ${log}"
        FAILED="true"
    else
        result="ok"
    fi

    echo "$(date '+%F %T') ${batch}: ${result}"
    RESULTS+=("$(printf '%-20s %s' "$batch" "$result")")

done

echo
echo "Summary:"
printf '%s\n' "${RESULTS[@]}"

[ "$FAILED" == "true" ] && exit 1
exit 0
