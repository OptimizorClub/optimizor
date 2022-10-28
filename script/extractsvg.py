#!/usr/bin/env python3

import subprocess
import os
import base64
import json
import sys

if len(sys.argv) == 1:
    returned_value = str(subprocess.check_output("FOUNDRY_PROFILE=test forge script test/OptimizorNFT.t.sol --use bin/solc", shell=True, cwd=os.path.dirname(__file__) + '/../'))
else:
    returned_value = sys.argv[1]

print(returned_value)

data = returned_value.split("base64,")[1].split('"')[0].split('\\n')[0]
metadata = base64.b64decode(data)
print(metadata)
with open('out.json', 'wb') as f:
    f.write(metadata)

image = json.loads(metadata)['image']
svg_data = base64.b64decode(image.split("base64,")[1])
with open('out.svg', 'wb') as f:
    f.write(svg_data)

attr = json.loads(metadata)['attributes']
print(attr)

desc = json.loads(metadata)['description']
print(desc)
