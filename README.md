# TextMate DBLP bundle

The goal of this bundle is to make it easier to query DBLP right from you favorite editor.

## Usage

Press `CTRL+Shift+D` to open a dialog box to perform a DBLP Query, as soon as the query returns a popover will present all possible papers from which you can select one. The appropriate citation will be inserted into the document.

## Install

To install with Git:

    mkdir -p ~/Library/Application\ Support/TextMate/Bundles
    cd ~/Library/Application\ Support/TextMate/Bundles
    git clone git://github.com/grundprinzip/DBLP.tmbundle.git "DBLP.tmbundle"
    osascript -e 'tell app "TextMate" to reload bundles'


To install without Git:

    mkdir -p ~/Library/Application\ Support/TextMate/Bundles
    cd ~/Library/Application\ Support/TextMate/Bundles
    wget http://github.com/grundprinzip/DBLP.tmbundle/tarball/master
    tar zxf grundprinzip-DBLP*.tar.gz
    rm grundprinzip-DBLP*.tar.gz
    mv grundprinzip-DBLP* "DBLP.tmbundle"
    osascript -e 'tell app "TextMate" to reload bundles'


## Prerequisites

* `gem install dblp`
* Ruby 1.8.7 or greater is required.


