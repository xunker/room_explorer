class Player {
  int currentRoomId, currentRoomX, currentRoomY;
  String name;

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

  Room (String roomName, int roomWidth, int roomLength) {
    name = roomName;
    width = roomWidth;
    length = roomLength;
    doors = new Door[maxDoors];
  }

  class Door {
    int roomX, roomY, type, targetRoomId, targetDoorId;
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

Player player = new Player("thePlayer", 0, 1, 1);

static int screenWidth = 640;
static int screenHeight = 480;
int unitSize = 10; // number of pixels in one unit, square

static int fillColour = 255;
static int textColour = 0;
static int backgroundColour = 200;

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

void setup() {
  rooms = new Room[4];

  rooms[0] = new Room("idx 0", 5, 5);
                //Arguments: x_pos, y_pos, door_type, target_room_id, target_door_id
  rooms[0].doors[0] = rooms[0].new Door(1, 0, X_DOOR_TYPE, 1, 0);
  rooms[0].doors[1] = rooms[0].new Door(0, 1, Y_DOOR_TYPE, 3, 1);
  // Infinite door! Goes back to same room on other side
  rooms[0].doors[2] = rooms[0].new Door(rooms[0].width, 1, Y_DOOR_TYPE, 0, 1);

  rooms[1] = new Room("idx 1", 3, 3);
  rooms[1].doors[0] = rooms[1].new Door(1, rooms[1].length, X_DOOR_TYPE, 0, 0);
  rooms[1].doors[1] = rooms[1].new Door(0, rooms[1].length-2, Y_DOOR_TYPE, 2, 1);

  rooms[2] = new Room("idx 2", 5, 10);
  rooms[2].doors[0] = rooms[1].new Door(rooms[2].width-2, rooms[2].length, X_DOOR_TYPE, 3, 0);
  rooms[2].doors[1] = rooms[1].new Door(rooms[2].width, rooms[2].length-2, Y_DOOR_TYPE, 1, 1);

  rooms[3] = new Room("idx 3", 10, 5);
  rooms[3].doors[0] = rooms[1].new Door(rooms[3].width-2, 0, X_DOOR_TYPE, 2, 0);
  rooms[3].doors[1] = rooms[1].new Door(rooms[3].width, 1, Y_DOOR_TYPE, 0, 1);

  size(640, 480, P3D);

  frameRate(30);
}

void draw() {
  background(backgroundColour);
  fill(fillColour);
  currentRoom = rooms[player.currentRoomId];
  printPlayerInfo();
  drawCurrentRoom();
  drawPlayer();

  noLoop(); // loop enabled in keyPressed()
}

void moveThroughDoor(Room.Door door) {
  println("Moving from room", rooms[player.currentRoomId].name , "(", player.currentRoomId, ") to", rooms[door.targetRoomId].name, " (", door.targetRoomId, ")");

  player.currentRoomId = door.targetRoomId;
  currentRoom = rooms[player.currentRoomId];

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
