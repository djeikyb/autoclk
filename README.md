components to scrape time clock data from an inaccessible app on an as400

Running `./week.pl` gives a plain-text dump of this week's time "card".

Running `./week.pl | ./csvihfy` transforms the dump into a csv file.

Depends on the perl module `DateTime`. Fedora 19 users can run `sudo yum install perl-DateTime`.
