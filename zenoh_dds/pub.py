from dataclasses import dataclass
from cyclonedds.domain import DomainParticipant
from cyclonedds.core import Qos, Policy
from cyclonedds.pub import DataWriter
from cyclonedds.topic import Topic
from cyclonedds.idl import IdlStruct
from time import sleep

# C, C++ require using IDL, Python doesn't
@dataclass
class Chatter(IdlStruct, typename="Chatter"):
    message: str

dp = DomainParticipant()
tp = Topic(dp, "key/expression", Chatter)
dw = DataWriter(dp, tp)

count = 0
while True:
    message = "Hello from DDS!! " + f"{count}"
    msg = Chatter(message=message)
    print("[pubdds]", msg.message)
    dw.write(msg)
    
    sleep(1)
    count = count + 1
