import random
from datetime import datetime

from paho.mqtt import client as mqtt_client

port = 1883
broker = "broker.hivemq.com"
topic = "INF1350_LIG4"
# Generate a Client ID with the subscribe prefix.
client_id = f'subscribe-{random.randint(0, 100)}'
# username = 'emqx'
# password = 'public'

count = 0

def connect_mqtt() -> mqtt_client:
    def on_connect(client, userdata, flags, rc):
        if rc == 0:
            print("Connected to MQTT Broker!")
        else:
            print("Failed to connect, return code %d\n", rc)

    client = mqtt_client.Client(client_id)
    # client.username_pw_set(username, password)
    client.on_connect = on_connect
    client.connect(broker)
    return client


def subscribe(client: mqtt_client):
    
    def on_message(client, userdata, msg):
        global file, count
        data = msg.payload.decode()
        print(f"Received `{data}` from `{msg.topic}` topic")
        
    client.subscribe(topic)
    client.on_message = on_message


def run():
    client = connect_mqtt()
    subscribe(client)
    client.loop_forever()


if __name__ == '__main__':
    run()