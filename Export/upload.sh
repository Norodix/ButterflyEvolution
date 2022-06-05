#!/bin/bash

cd "${0%/*}" #must change to own directory for bash
cp ./ButterflyEvolution_HTML5/ButterflyEvolution.html ./ButterflyEvolution_HTML5/index.html 
make
butler push ButterflyEvolution_HTML5        Norodix/butterfly-evolution:html
butler push ButterflyEvolution_Windows.zip  Norodix/butterfly-evolution:windows
butler push ButterflyEvolution_Linux.zip    Norodix/butterfly-evolution:linux
