#import context 
import paho.mqtt.subscribe as subscribe
import os
from google.cloud import pubsub_v1
from proto import STRING
import json
import base64

#TODO Base64=>Ascii


alphabet={
    "A":"000000",
    "B":"000001",
    "C":"000010",
    "D":"000011",
    "E":"000100",
    "F":"000101",
    "G":"000110",
    "H":"000111",
    "I":"001000",
    "J":"001001",
    "K":"001010",
    "L":"001011",
    "M":"001100",
    "N":"001101",
    "O":"001110",
    "P":"001111",
    "Q":"010000",
    "R":"010001",
    "S":"010010",
    "T":"010011",
    "U":"010100",
    "V":"010101",
    "W":"010110",
    "W":"010111",
    "Y":"011000",
    "Z":"011001",

    "a":"011010",
    "b":"011011",
    "c":"011100",
    "d":"011101",
    "e":"011110",
    "f":"011111",
    "g":"100000",
    "h":"100001",
    "i":"100010",
    "j":"100011",
    "k":"100100",
    "l":"100101",
    "m":"100110",
    "n":"100111",
    "o":"101000",
    "p":"101001",
    "q":"101010",
    "r":"101011",
    "s":"101100",
    "t":"101101",
    "u":"101110",
    "v":"101111",
    "w":"110000",
    "x":"110001",
    "y":"110010",
    "z":"110011",

    "0":"110100",
    "1":"110101",
    "2":"110110",
    "3":"110111",
    "4":"111000",
    "5":"111001",
    "6":"111010",
    "7":"111011",
    "8":"111100",
    "9":"111101",
    "+":"111110",
    "/":"111111"
}


def base36decode(number):
    res=""
    for i in range(len(number)):
      res+=alphabet[number[i]]
    res2=""
    i=0
    while(i<len(res)):
        res2+=str(hex(int(res[i:i+4],2)))[2:3]
        i+=4
    return res2


#Preparations to publish to google cloud (mqtt pubsub)
publisher = pubsub_v1.PublisherClient()
topic_name = 'projects/iotmalengre/topics/RaspiData'.format(
    project_id=os.getenv('GOOGLE_CLOUD_PROJECT'),
    topic='RaspiData',  # Set this to something appropriate.
)
#publisher.create_topic(name=topic_name)

while 1:

    #Retrieving data from ttn mqtt
    m = subscribe.simple(topics=['#'], hostname="eu1.cloud.thethings.network", port=1883, auth={'username':"malpytestappid@ttn",'password':"NNSXS.FSRXLMBXD6TUFCDWZMU2L5HDAHFGGCVXHYQSB7A.FMKA5WOE6D7X4YVQPFBJDNL67FZKAR3URQ6ITOEHFCHXEVSENZZQ"}, msg_count=2)
    for a in m:

        topic=a.topic
        payload = "[No payload]"
        #FULL INFO : a.payload => For now only extracting msg but there is a ton of info in there

        #If payload, extract it and print it
        sliced=str(a.payload)[2:len(a.payload)+2]
        my_dict = json.loads(sliced)

        params = my_dict.get("uplink_message",None)  
        timestamp = my_dict.get("received_at",None)      
        if(params):
            paramstr=str(params).replace("\'", "\"")
            payload = json.loads(paramstr).get('frm_payload')

            #Translation
            res=base36decode(payload)
            print("Translated received msg : ",res,"\n\tTopic: ",topic,"\n") 

            dic={
                #"float":22.2, #Does this create the error table in BigQuery ?
                "White_Temperature":float(res[0:4])/100,#22.2,
                "White_Humidity":float(res[4:8])/100,
                "White_Pressure":float(res[8:12])/100,
                "Green_Frequency1":float(res[12:16])/100,
                "Green_Frequency2":float(res[16:20])/100,
                "Green_Frequency3":float(res[20:24])/100,
                "Black_TemperaturePt1000":float(res[24:28])/100,
                "ts":timestamp
            }

            #Publish to google cloud  
            future = publisher.publish(topic_name, str.encode(json.dumps(dic)), spam='eggs')
            print("Sent! Messsage id : ",future.result())

        else: print("Data without payload. Topic : ",topic)
