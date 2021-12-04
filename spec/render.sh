#!/bin/bash

markdown sync.md > sync.html
~/node_modules/.bin/mmdc -i sync.md -o sync-diagrams/diagram.svg

markdown user-flows.md > user-flows.html
~/node_modules/.bin/mmdc -i user-flows.md -o user-flows-diagrams/diagram.svg

markdown states.md > states.html
