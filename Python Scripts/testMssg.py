fPath   = r"C:\Users\Williamson_Lab\slackContactFile.txt"
print(fPath)
mssg    = ("Experiment " + "a" + " ran successfully")
# mssg    = ("Experiment " + experimentName + " ran successfully")
iconURL = "https://raw.githubusercontent.com/MouseLand/suite2p/main/suite2p/logo/logo_unshaded.png"

import requests
import json
webhook_url = ''
data = { 'name': 'This is an example for webhook' }
requests.post(webhook_url, data=json.dumps(data), headers={'Content-Type': 'application/json'})


from sendSlackMssg import sendMssg
sendMssg(fPath,mssg,iconURL)
