// messages to be displayed to the user, that will go away after `expiresIn` moves
class Message {
  String text;
  int expiresIn;

  // These there store the time when the message was added
  private int seconds;
  private int minutes;
  private int hours;

  // Add message with default expiresIn value
  Message(String messageText) {
    text = messageText;
    expiresIn = 20;
    setTimestamp();
  }

  // Add message with custom expiresIn value
  Message(String messageText, int expiresInCount) {
    text = messageText;
    expiresIn = expiresInCount;
    setTimestamp();
  }

  // decrement expiresIn by one to a minimum of 0
  void decrement() {
    if (expiresIn > 0)
      expiresIn--;
  }

  boolean isExpired() {
    return (expiresIn <= 0);
  }

  // Print out the message preceeded by the time it was added
  String textWithTimestamp() {
    return "(" + nf(hours, 2) + ":" + nf(minutes,2) + ":" + nf(seconds,2) + ") " + text;
  }

  private void setTimestamp() {
    seconds = second();
    minutes = minute();
    hours = hour();
  }
}

class Player {
  int currentRoomId, currentRoomX, currentRoomY;
  String name;

  ArrayList<Message> messages = new ArrayList<Message>();

  // roomId is the rooms[] array index of the room
  Player (String playerName, int roomId, int xPos, int yPos) {
    name = playerName;
    currentRoomId = roomId;
    currentRoomX = xPos;
    currentRoomY = yPos;
  }
}

static int X_DOOR_TYPE = 0;
static int Y_DOOR_TYPE = 1;

class Room {
  int maxDoors = 3;
  String name;
  int width, length;
  Door[] doors;

  // enterMessage is optional message that will be printed when player first
  // enters this room. Must be set separately from constructor.
  String enterMessage;

  Room (String roomName, int roomWidth, int roomLength) {
    name = roomName;
    width = roomWidth;
    length = roomLength;
    doors = new Door[maxDoors];
  }

  class Door {
    int roomX, roomY, type, targetRoomId, targetDoorId;

    // message is optional message that will be printed when player goes through this door.
    // Must be set separately from constructor.
    String message;

    // doorType: X_DOOR_TYPE or Y_DOOR_TYPE
    // targetRoomId is the rooms[] array index of the room
    // targetDoorId is the Room.doors[] array index of the target door
    Door (int x, int y, int doorType, int targetRoom, int targetDoor) {
      roomX = x;
      roomY = y;
      type = doorType;
      targetRoomId = targetRoom;
      targetDoorId = targetDoor;
    }
  }
}

// class House {
//   Room[] rooms;

//   House (int maxRooms) {
//     rooms = new Room[maxRooms];
//   }
// }

Room[] rooms;
Room currentRoom;

// Player player = new Player("thePlayer", 0, 1, 1);
Player player;

static int screenWidth = 640;
static int screenHeight = 480;
int unitSize = 10; // number of pixels in one unit, square

static int fillColour = 255;
static int textColour = 0;
static int backgroundColour = 200;
static int labelTextSize = 12;

// Convert width/length of units to pixels
int asPixels(int units) {
  return units * unitSize;
}

int fromCentreX(int coord) {
  return (screenWidth / 2) - (coord  / 2);
}

int fromCentreY(int coord) {
  return (screenHeight / 2) - (coord  / 2);
}

void drawCurrentRoom() {
  rect(
    fromCentreX(unitSize)-asPixels(player.currentRoomX),
    fromCentreY(unitSize)-asPixels(player.currentRoomY),
    asPixels(currentRoom.width),
    asPixels(currentRoom.length)
  );

  // room label
  fill(textColour);
  text(currentRoom.name, fromCentreX(unitSize)-asPixels(player.currentRoomX), fromCentreY(unitSize)-asPixels(player.currentRoomY)-1, 1);
  fill(fillColour);

  // doors
  for (Room.Door door : currentRoom.doors) {
    if (door == null) { continue; }

    if (door.type == X_DOOR_TYPE) {
      rect(
        fromCentreX(unitSize)-asPixels(player.currentRoomX)+asPixels(door.roomX),
        fromCentreY(unitSize)-asPixels(player.currentRoomY)+asPixels(door.roomY)-1,
        unitSize,
        2
      );
    } else if (door.type == Y_DOOR_TYPE) {
      rect(
        fromCentreX(unitSize)-asPixels(player.currentRoomX)+asPixels(door.roomX)-1,
        fromCentreY(unitSize)-asPixels(player.currentRoomY)+asPixels(door.roomY),
        2,
        unitSize
      );
    } else {
      println("Error unknown door type:", door.type);
    }
  }
}

void drawPlayer() {
  circle(screenWidth / 2, screenHeight / 2, unitSize);
}

void drawPlayerMessages() {
  // Draw any messages the user may have
  fill(textColour);
  int currentRow = int(screenHeight / labelTextSize) - player.messages.size();

  for (Message message : player.messages) {
    text(message.textWithTimestamp(), 0, labelTextSize*currentRow);
    currentRow++;
    message.decrement(); // decrement expiresIn on the message
  }

  // remove expired messages from the list
  for (int i = 0; i < player.messages.size() ; i++) {
    Message message = player.messages.get(i);

    // remove expired messages from our list
    if (message.isExpired())
      player.messages.remove(i);
  }
}

void drawPlayerInfo() {
  String[] msgs = {
    "Current room: " + currentRoom.name + " (index: " + player.currentRoomId + ")",
    "Position: " + player.currentRoomX + ", " + player.currentRoomY
  };

  fill(textColour);
  int currentRow = 1;
  for (String msg : msgs) {
    text(msg, fromCentreX(int(textWidth(msg))), labelTextSize*currentRow);
    currentRow++;
  }
  fill(fillColour);
}

void setup() {
  rooms = new Room[6];

  rooms[0] = new Room("First", 5, 5);

  /*
  arguments: new Door(x_pos, y_pos, door_type, target room index, target door index)

  x_pox, y_pos:
    x and y coordinates where the door will appear in the room

  door_type:
    X_DOOR_TYPE (door on vertical wall) or Y_DOOR_TYPE (door on horizontal wall)

  target room index:
    the room where this door leads, as the index of room in the `rooms` array

  target door index:
    the door in target room where player will come of out, it is the index of the door inside that rooms' `doors` array.
  */
  rooms[0].doors[0] = rooms[0].new Door(1, 0, X_DOOR_TYPE, 1, 0);
  rooms[0].doors[1] = rooms[0].new Door(0, 1, Y_DOOR_TYPE, 3, 1);
  // Infinite door! Goes back to same room on other side
  rooms[0].doors[2] = rooms[0].new Door(rooms[0].width, 1, Y_DOOR_TYPE, 0, 1);
  rooms[0].doors[2].message = "You have re-appeared in the same room you just left!";

  rooms[1] = new Room("Second", 3, 3);
  rooms[1].doors[0] = rooms[1].new Door(1, rooms[1].length, X_DOOR_TYPE, 0, 0);
  rooms[1].doors[1] = rooms[1].new Door(0, rooms[1].length-2, Y_DOOR_TYPE, 2, 1);

  rooms[2] = new Room("Third", 5, 10);
  rooms[2].doors[0] = rooms[2].new Door(rooms[2].width-2, rooms[2].length, X_DOOR_TYPE, 3, 0);
  rooms[2].doors[1] = rooms[2].new Door(rooms[2].width, rooms[2].length-2, Y_DOOR_TYPE, 1, 1);

  rooms[3] = new Room("Fourth", 10, 5);
  rooms[3].doors[0] = rooms[3].new Door(rooms[3].width-2, 0, X_DOOR_TYPE, 2, 0);
  rooms[3].doors[1] = rooms[3].new Door(rooms[3].width, 1, Y_DOOR_TYPE, 0, 1);
  // Door to hallway (index 4)
  rooms[3].doors[2] = rooms[3].new Door(0, 1, Y_DOOR_TYPE, 4, 1);

  rooms[4] = new Room("Hallway", 5, 1);
  rooms[4].doors[0] = rooms[4].new Door(0, 0, Y_DOOR_TYPE, 5, 0);
  rooms[4].doors[1] = rooms[4].new Door(rooms[4].width, 0, Y_DOOR_TYPE, 3, 2);

  // Dead-end room, only one door back to hallway
  rooms[5] = new Room("Fifth (dead end)", 10, 10);
  rooms[5].enterMessage = "Ha! There is no escape! Turn back!";
  rooms[5].doors[0] = rooms[5].new Door(rooms[5].width, rooms[5].length/2, Y_DOOR_TYPE, 4, 0);

  // new Player Arguments: name, room index, room x, room y
  player = new Player("thePlayer", 0, 1, 1);
  player.messages.add(new Message("Welcome to the game!"));

  size(640, 480, P3D);
  textSize(labelTextSize);

  frameRate(30);
}

void draw() {
  background(backgroundColour);
  fill(fillColour);

  currentRoom = rooms[player.currentRoomId];
  printPlayerInfo();
  drawCurrentRoom();
  drawPlayer();
  drawPlayerMessages();
  drawPlayerInfo();

  noLoop(); // loop enabled in keyPressed()
}

void moveThroughDoor(Room.Door door) {
  println("Moving from room", rooms[player.currentRoomId].name , "(", player.currentRoomId, ") to", rooms[door.targetRoomId].name, " (", door.targetRoomId, ")");

  player.currentRoomId = door.targetRoomId;
  currentRoom = rooms[player.currentRoomId];

  // load any enterMessages for this room
  if ((currentRoom.enterMessage != null) && (currentRoom.enterMessage.length() > 0)) {
    player.messages.add(new Message(currentRoom.enterMessage));
  }

  // load any messages for using this door
  if ((door.message != null) && (door.message.length() > 0)) {
    player.messages.add(new Message(door.message));
  }

  if (currentRoom.doors[door.targetDoorId].type == X_DOOR_TYPE) {
    if (currentRoom.doors[door.targetDoorId].roomX > 0) {
      player.currentRoomX = currentRoom.doors[door.targetDoorId].roomX;
    } else {
      player.currentRoomX = 0;
    }

    if (currentRoom.doors[door.targetDoorId].roomY > 0) {
      player.currentRoomY = currentRoom.doors[door.targetDoorId].roomY-1;
    } else {
      player.currentRoomY = 0;
    }

  } else if (currentRoom.doors[door.targetDoorId].type == Y_DOOR_TYPE) {
    if (currentRoom.doors[door.targetDoorId].roomY > 0) {
      player.currentRoomY = currentRoom.doors[door.targetDoorId].roomY;
    } else {
      player.currentRoomY = 0;
    }

    if (currentRoom.doors[door.targetDoorId].roomX > 0) {
      player.currentRoomX = currentRoom.doors[door.targetDoorId].roomX-1;
    } else {
      player.currentRoomX = 0;
    }

  } else {
    println("Unknown door type:", currentRoom.doors[door.targetDoorId].type);
  }
}

void printPlayerInfo() {
  println("Player) Room:", currentRoom.name, " X:", player.currentRoomX, " Y:", player.currentRoomY);
}

void printUnitSize() {
  println("unitSize:", unitSize);
}

void handleCollision(int keyCode) {
  boolean wayBlocked = true;

  /* If moving DOWN or RIGHT we need to add 1 to X or Y before the comparison,
     so we copy the players current X/Y coordinated to a variable so we can
     add 1 to them depending in the direction we're going */
  int currentRoomX = player.currentRoomX;
  int currentRoomY = player.currentRoomY;
  if (keyCode == RIGHT)
    currentRoomX += 1;
  if (keyCode == DOWN)
    currentRoomY += 1;

  for (Room.Door door : currentRoom.doors) {
    if (door == null) { continue; }
    if ((door.roomX == currentRoomX) && (door.roomY == currentRoomY)) {
      wayBlocked = false;
      moveThroughDoor(door);
      loop();
      return;
    }
  }

  if (wayBlocked)
    println("blocked");
}

void keyPressed() {
  // println("keyPressed: ", keyCode);

  if (keyCode == 61) { // + key
    if (unitSize < 50)
      unitSize+=5;
    printUnitSize();
  }

  if (keyCode == 45) { // - key
    if (unitSize > 10)
      unitSize-=5;
    printUnitSize();
  }

  if (keyCode == UP) {
    if (player.currentRoomY > 0) {
      player.currentRoomY--;
    } else {
      handleCollision(keyCode);
    }

  } else if (keyCode == DOWN) {
    if (player.currentRoomY < currentRoom.length-1) {
      player.currentRoomY++;
    } else {
      handleCollision(keyCode);
    }

  } else if (keyCode == LEFT) {
    if (player.currentRoomX > 0) {
      player.currentRoomX--;
    } else {
      handleCollision(keyCode);
    }

  } else if (keyCode == RIGHT) {
    if (player.currentRoomX < currentRoom.width-1) {
      player.currentRoomX++;
    } else {
      handleCollision(keyCode);
    }
  }

  loop(); // loop disabled in draw()
}
