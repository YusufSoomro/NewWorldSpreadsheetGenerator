# New World Spreadsheet Generator for Builds
Welcome! This set of ruby scripts is meant to take the provided info from all-builds.yml, scrape the page provided from the URL in the YAML file, and spit out a CSV which you can import into a spreadsheet wherever you want.

The only interface to run it is by running this command in the parent directory of this project within a terminal: `ruby builds/generate_csv.rb`.

More builds will be added to `all-builds.yml` soon and you'll be able to compare the stats of each one with each other.