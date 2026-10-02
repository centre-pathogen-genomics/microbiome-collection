#!/bin/bash

# usage: SCRIPTS/check_manifest.sh inputmanifest

# validates the input manifest before running the pipeline
# expects a headerless TSV with four columns:
# column 1 is the DMG ID
# column 2 is the CMC ID
# column 3 is paths to forward reads
# column 4 is paths to reverse reads

MANIFEST=$1

if [ ! -s "$MANIFEST" ] ; then

  echo "Manifest file not found or empty: $MANIFEST"
  exit 1

fi

inputerror="false"

# windows line endings break file paths
if grep -q $'\r' "$MANIFEST" ; then

  echo "Manifest contains Windows (CRLF) line endings - fix with: sed -i 's/\r$//' $MANIFEST"
  inputerror="true"

fi

# the last row is silently skipped by 'while read' loops if there is no trailing newline
if [ -n "$(tail -c 1 "$MANIFEST")" ] ; then

  echo "Manifest does not end with a newline - the last row would be skipped"
  inputerror="true"

fi

# each row must have exactly four non-empty, tab-separated columns with no spaces
awk -F '\t' '
  {
    for (i = 1; i <= NF; i++) {
      if ($i ~ / /) { printf "Line %d: column %d contains spaces: %s\n", NR, i, $i ; bad = 1 }
    }
  }
  NF != 4 { printf "Line %d: expected 4 tab-separated columns, found %d\n", NR, NF ; bad = 1 ; next }
  {
    for (i = 1; i <= 4; i++) {
      if ($i == "") { printf "Line %d: column %d is empty\n", NR, i ; bad = 1 }
    }
    if ($3 == $4) { printf "Line %d: R1 and R2 are the same file\n", NR ; bad = 1 }
  }
  END { exit bad }
' "$MANIFEST" || inputerror="true"

# IDs and read files must be unique
for col in 1 2 3 4 ; do

  dups=$(cut -f "$col" "$MANIFEST" | sort | uniq -d)

  if [ -n "$dups" ] ; then

    echo "Duplicate values in column ${col}:"
    echo "$dups"
    inputerror="true"

  fi

done

# all read files must exist and be non-empty
while IFS=$'\t' read -r dmg cmc r1 r2 ; do

  if [ -n "$r1" ] && [ ! -s "$r1" ] ; then

    echo "File not found or empty: $r1"
    inputerror="true"

  fi

  if [ -n "$r2" ] && [ ! -s "$r2" ] ; then

    echo "File not found or empty: $r2"
    inputerror="true"

  fi

done < "$MANIFEST"

if [ "$inputerror" == "true" ] ; then

  echo "Manifest failed validation. Exiting."
  exit 1

fi

echo "Manifest passed validation: $(wc -l < "$MANIFEST" | tr -d ' ') isolates"
