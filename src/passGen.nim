import
  std/random,
  std/re,
  std/sequtils,
  std/strutils,
  std/tables,
  pkg/owlkettle

const
  Chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ123456789"
  DefaultLength = 8

proc generateRandomString(chars: seq[char], length: Natural): string =
  randomize()
  result = ""
  for i in 0..<length:
    let index = rand(chars.len - 1)
    result.add chars[index]

viewable App:
  password: string
  length: int = DefaultLength
  validEntry: bool = true
  includings: Table[string, bool] = {"number": true, "upper": true,
      "lower": true}.toTable
  isCopied: bool

method view(app: AppState): Widget =
  result = gui:
    Window(title = "passGen"):
      defaultSize = (500, 200)
      Box(orient = OrientY, margin = 8, spacing = 4):
        Box(orient = OrientX, margin = 2, spacing = 4) {.expand: false.}:
          Box(orient = OrientX) {.expand: false.}:
            Label(text = "文字数：")

            Entry:
              text = block:
                if app.length == -1: ""
                else: $app.length
              style = block:
                if app.validEntry: {EntrySuccess}
                else: {EntryError}
              proc changed(text: string) =
                if text =~ re"\d":
                  app.length = text.parseInt
                  app.validEntry = true
                elif text == "":
                  app.length = -1
                  app.validEntry = false
                else:
                  app.validEntry = false

          Frame(label = "含む文字"):
            FlowBox:
              Box(orient = OrientX, margin = 4, spacing = 4):
                CheckButton:
                  state = app.includings["number"]
                  proc changed(state: bool) =
                    app.includings["number"] = state
                    if not app.includings.values.toSeq.anyIt(it):
                      app.includings["number"] = true
                Label(text = "数字")
                CheckButton:
                  state = app.includings["upper"]
                  proc changed(state: bool) =
                    app.includings["upper"] = state
                    if not app.includings.values.toSeq.anyIt(it):
                      app.includings["upper"] = true
                Label(text = "大文字")
                CheckButton:
                  state = app.includings["lower"]
                  proc changed(state: bool) =
                    app.includings["lower"] = state
                    if not app.includings.values.toSeq.anyIt(it):
                      app.includings["lower"] = true
                Label(text = "小文字")

        Box {.vAlign: AlignStart.}:
          orient = OrientX
          margin = 8
          spacing = 4
          Button {.expand: false, hAlign: AlignStart.}:
            text = "Generate"
            tooltip = "Generate password"
            proc clicked =
              var chars = Chars.items.toSeq
              if not app.includings["number"]:
                chars.keepItIf(($it =~ re"[^0-9]"))
              if not app.includings["upper"]:
                chars.keepItIf(($it =~ re"[^A-Z]"))
              if not app.includings["lower"]:
                chars.keepItIf(($it =~ re"[^a-z]"))

              app.password = generateRandomString(chars, app.length)
              app.isCopied = false

          Entry {.expand: false, hAlign: AlignCenter.}:
            text = app.password
            proc changed(text: string) =
              app.password = text

          Button {.expand: false.}:
            text = block:
              if app.isCopied: "Copied!"
              else: "Click to copy"
            sensitive = app.password != ""
            proc clicked =
              app.isCopied = true
              app.writeClipboard app.password

brew(gui(App()))
