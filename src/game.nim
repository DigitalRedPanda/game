import x11/[xlib, x]


const 
  up = 119
  down = 115
  left = 97
  right = 100

var channel: Channel[cstring]


const
  animation = [
  """
 o◞
◞|
◞ ◟
""",
"""
 o/
/|
/ \
""",
"""
 o◞
◞|
◞ ◟
""",
"""
 o
▁|▔
/ \
""",
"""
 o
▇|▇
▓ ▓
""",
"""
◟o
 |◟
◞ ◟
""",
"""
\o
 |\
/ \
""",
"""
 o
▔|▁
/ \
""",
"""
 o
▇|▇
▓ ▓
""",
  ]
  default = """
 o
/|\
▕▕
"""


proc animate() {.thread.} = 
  var currentRunIdx = 0
  while true:
    let direction = channel.tryRecv()
    if direction.dataAvailable:
      case direction.msg:
        of "s": discard
        else: discard
    inc currentRunIdx
  discard

proc main() = 
  let
    display = XOpenDisplay(nil)
  
  var thread: Thread[void]
  createThread(thread, animate)

  discard XGrabKeyboard(display, DefaultRootWindow(display), false.XBool, GrabModeAsync, GrabModeAsync, CurrentTime)  
 
  channel.open()

  defer: 
    discard display.XUnGrabKeyboard(CurrentTime)
    discard display.XCloseDisplay()

  var 
    event: PXEvent
    character = '\0'
  while true:
    discard display.XNextEvent(event)
    if event.theType == KeyPress:
      let key = XLookupKeysym(addr event.xkey, 0)
      if key <= 128:
        character = char key
        case key:
          of left:
            channel.send("a")
          of right:
            channel.send("d")
          of down:
            channel.send("s")
          of up:
            channel.send("w")
          else: 
            discard
    else: 
      let key = XLookupKeysym(addr event.xkey, 0)
      
      if key <= 128:
        character = char key
        case key:
          of left:
            channel.send("as")
          of right:
            channel.send("ds")
          of down:
            channel.send("ss")
          of up:
            channel.send("ws")
          else: 
            discard
    
      discard
main()
