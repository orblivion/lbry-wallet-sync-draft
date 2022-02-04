#!/bin/bash

markdown user-flows.md > user-flows.html
~/node_modules/.bin/mmdc -i user-flows.md -o user-flows-diagrams/diagram.svg
