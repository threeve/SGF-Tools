#!/bin/sh

# SGF-Tools Spotlight Importer postinstall.sh

echo telling mdimport to reindex all SGF files
su ${USER} -c "/usr/bin/mdimport -r '/Library/Spotlight/SGF.mdimporter'"
