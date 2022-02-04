#!/bin/bash

markdown sync.md > sync.html
~/node_modules/.bin/mmdc -i sync.md -o sync-diagrams/diagram.svg
