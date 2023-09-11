import json
import sys
import random
import requests
if __name__ == '__main__':
    url = "https://hooks.slack.com/services/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"
    message = ("New Message")
    #title = (f"New Incoming Message :zap:")
    slack_data = {
        "username": "Code Notification",
        #"icon_emoji": ":1234:",
        "icon_url": "https://raw.githubusercontent.com/MouseLand/suite2p/main/suite2p/logo/logo_unshaded.png",
        #"channel" : "#somerandomcahnnel",
        "attachments": [
            {
                "color": "#9733EE",
                "fields": [
                    {
                        #"title": title,
                        "value": message,
                        "short": "false",
                    }
                ]
            }
        ]
    }
    byte_length = str(sys.getsizeof(slack_data))
    headers = {'Content-Type': "application/json", 'Content-Length': byte_length}
    response = requests.post(url, data=json.dumps(slack_data), headers=headers)
    if response.status_code != 200:
        raise Exception(response.status_code, response.text)
