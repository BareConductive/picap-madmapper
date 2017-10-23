import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress madMapper;
int value = 0;

int numElectrodes  = 12;
int[] status, lastStatus;
String[] mediasList = new String [numElectrodes];

void updateArrayOSC(int[] array, Object[] data) {
  if (array == null || data == null) {
    return;
  }

  for (int i = 0; i < min(array.length, data.length); i++) {
    array[i] = (int)data[i];
  }
}

void setup() {
  // setup OSC receiver on port 3000
  oscP5 = new OscP5(this, 3000);
  madMapper = new NetAddress("127.0.0.1", 8010);
  
  status            = new int[numElectrodes];
  lastStatus        = new int[numElectrodes];
  
  mediasList[0] = "bubble_animation.mp4";
  mediasList[1] = "square_animation.mp4";
}

void oscEvent(OscMessage oscMessage) {
    if (oscMessage.checkAddrPattern("/touch")) {
      updateArrayOSC(status, oscMessage.arguments());
    }
    
    for (int i = 0; i < numElectrodes; i++) {
      if (lastStatus[i] == 0 && status[i] == 1) {
        // touched
        println("Electrode " + i + " was touched");
        lastStatus[i] = 1;
        sendMMMessage(true, i);
      } 
      else if(lastStatus[i] == 1 && status[i] == 0) {
        // released
        println("Electrode " + i + " was released");
        lastStatus[i] = 0;
        sendMMMessage(false, i);
      }
    }
}

void sendMMMessage(boolean begin, int electrode) {
  OscMessage msg = new OscMessage("/medias/" + mediasList[electrode] + "/begin");
  msg.add(begin);
  
  // send it to MadMapper
  oscP5.send(msg, madMapper);
}