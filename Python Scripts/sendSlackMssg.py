def sendMssg(fPath,mssgTxt,iconURL):
    import json
    import sys
    import random
    import requests

    # fPath = r"C:\Users\Williamson_Lab\slackContactFile"
    with open(fPath) as f:
        link = f.readlines()

    if True:
        url = link[0]
        message = mssgTxt
        # message = ("Experiment " + experimentName + " ran successfully")
        #title = (f"New Incoming Message :zap:")
        slack_data = {
            "username": "Suite2p",
            #"icon_emoji": ":1234:",
            # "icon_url": "https://raw.githubusercontent.com/MouseLand/suite2p/main/suite2p/logo/logo_unshaded.png",
            "icon_url": iconURL,
            #"channel" : "#somerandomcahnnel",
            "attachments": [
                {
                    #"color": "#9733EE",
                    "fields": [
                        {
                            #"title": "S2P Output",
                            "preview": "Data ready for selection",
                            "value": message,
                            "short": "S2P Output",
                        }
                    ]
                }
            ]
        }
        byte_length = str(sys.getsizeof(slack_data))
        headers = {'Content-Type': "application/json", 'Content-Length': byte_length}
        # import pdb; pdb.set_trace()
        response = requests.post(url, data=json.dumps(slack_data), headers=headers)
        if response.status_code != 200:
            raise Exception(response.status_code, response.text)