import subprocess
import base64
import json

returned_value = str(subprocess.check_output("forge script ../test/OptimizorNFT.t.sol", shell=True))
print(returned_value)
data = returned_value.split("base64,")[1].split('"')[0]
image = json.loads(base64.b64decode(data))['image']
attr = json.loads(base64.b64decode(data))['attributes']
svg_data = base64.b64decode(image.split("base64,")[1])
f = open('out.svg', 'wb')
f.write(svg_data)
f.close()
print(attr)
