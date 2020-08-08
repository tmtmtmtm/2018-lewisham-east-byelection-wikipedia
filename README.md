
The code and queries etc here are unlikely to be updated as my process
evolves. Later repos will likely have progressively different approaches
and more elaborate tooling, as my habit is to try to improve at least
one part of the process each time around.

---------

Step 1: Scrape the results
==========================

```sh
bundle exec ruby scraper.rb https://en.wikipedia.org/wiki/2018_Lewisham_East_by-election | tee wikipedia.csv
```

Step 2: Generate possible missing IDs
=====================================

```sh
xsv search -v -s id 'Q' wikipedia.csv | xsv select name | tail +2 |
  sed -e 's/^/"/' -e 's/$/"@en/' | paste -s - |
  xargs -0 wd sparql find-candidates.js |
  jq -r '.[] | [.name, .item.value, .election.label, .constituency.label, .party.label] | @csv' |
  tee candidates.csv
```

The two found look like good matches, but there are no matches for:

* Charles Edward Carey
* Lucy Salek
* Mandu Reid
* Massimo DiMambro
* Patrick Gray
* Ross Archer
* Sean Finch
* Thomas Hall

Mandu Reid not only has a Wikidata item, but also a Wikipedia page, so
I've edited the page to link to that.

Sean Finch also stood in the general election, but Wikdiata knows him as 
Sean Edward Finch (Q76119883), so I've added an alias for this form.

Similarly, Thomas Hall already exists as Thomas Bartholomew Hall
(Q76120082), so I've added an alias for that too.

After adding al these, I regenerated both CSV files.

Step 3: Combine Those
=====================

```sh
xsv join -n --left 2 wikipedia.csv 1 candidates.csv | xsv select '7,1-5' | sed $'1i\\\nfoundid' > combo.csv
```

Step 4: Generate QuickStatements commands
=========================================

Tweak config variables in `generate-qs.rb`, and then:

```sh
bundle exec ruby generate-qs.rb | tee commands.qs
```

Then sent to QuickStatements as https://tools.wmflabs.org/editgroups/b/QSv2T/1596914379403
