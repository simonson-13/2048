//-----------------------------START: CODE FROM ASSGIN3----------------------------

//  ContentView.swift
//  assign3
//
//  Created by Simon Liao on 10/14/21.


import SwiftUI

struct toggleView: View {
    @EnvironmentObject var twos : Twos

    var body: some View {
        //testing
        Picker("testing", selection: $twos.isRandom) {
            Text("Random").tag(true)
            Text("Determ").tag(false)
        }
        .pickerStyle(SegmentedPickerStyle())
        .frame(width: 350, height: 50, alignment: .center)
    }
}

struct ButtonView: View {
   @State private var buttonText = "Push me!"
   var body: some View {
      Button(buttonText, action: f)
   }
   func f() {
      buttonText = "You pushed the button!"
   }
}

struct buttonView: View {
    @EnvironmentObject var twos : Twos


    var body: some View {
        //up
        Button(action: {twos.collapse(dir: .up)}, label: {
            VStack (spacing: 10){
                Text("Up")
                    .font(.title)
            }
        })
        .padding()
        .frame(width: 105, height: 60, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        .border(Color.blue, width: 3)


        HStack (spacing: 50){
            //left
            Button(action: {twos.collapse(dir: .left)}, label: {
                VStack (spacing: 10){
                    Text("Left")
                        .font(.title)
                }
            })
            .padding()
            .frame(width: 105, height: 60, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            .border(Color.blue, width: 3)

            //right
            Button(action: {twos.collapse(dir: .right)}, label: {
                VStack (spacing: 10){
                    Text("Right")
                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                }
            })
            .padding()
            .frame(width: 105, height: 60, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            .border(Color.blue, width: 3)
        }

        //down
        Button(action: {twos.collapse(dir: .down)}, label: {
            VStack (spacing: 10){
                Text("Down")
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
            }
        })
        .padding()
        .frame(width: 105, height: 60, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        .border(Color.blue, width: 3)

        //New Game
        Button(action: {twos.isGameOver = true}, label: {
            VStack (spacing: 10){
                Text("New Game")
                    .font(.title)
            }
        })
        .padding()
        .frame(width: 210, height: 60, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        .border(Color.blue, width: 3)

    }
}

struct scoreView: View {
    private var score: Int

    init(_ inputScore: Int) {
        score = inputScore
    }

    var body: some View {
        HStack (spacing: 6) {
            Text("Score:")
                .frame(height: 50, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .font(.title)
            Text("\(score)")
                .font(.title)
        }
    }
}

struct tileView: View {
    @EnvironmentObject var twos : Twos
    @Binding private var tile : Tile
    private var offsetMulitplier: Int = 75
    var valToColor : [Int: Color] = [
        0: Color.gray,
        2: Color.yellow,
        4: Color.orange,
        8: Color.red,
        16: Color.purple,
        32: Color.blue,
        64: Color.purple,
        128: Color.green,
        256: Color.orange,
        512: Color.yellow,
        1028: Color.gray,
        2048: Color.black
    ]

    init(_ newTile : Binding<Tile>) {
        self._tile = newTile
    }
    
    func printVal(_ a: Int) -> String {
        if(a == 0) {return ""}
        else {return String(a)}
    }
    
    var body: some View {
        Text("\(printVal(tile.val))")
            .font(.title)
            .bold()
            .fixedSize(horizontal: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
            .frame(width: 70, height: 70, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            .background(valToColor[tile.val])
            .cornerRadius(10)
            .offset(x: CGFloat(tile.col*offsetMulitplier), y: CGFloat(tile.row*offsetMulitplier))
            .animation(.easeInOut(duration: 1))
    }
}

struct boardView: View {
    @EnvironmentObject var twos : Twos
    @State private var offset = CGSize.zero
    private var board : [Tile]

    init(_ inputBoard: [Tile]) {
        board = inputBoard
    }

    var body: some View {
        ZStack {
            ForEach(0..<16, id: \.self) {i in
                if(twos.board[i].val != 0) {
                    tileView($twos.board[i]).frame(width: 300, height: 300, alignment: .topLeading).environmentObject(twos)
                }
            }
        }
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    self.offset = gesture.translation
                }
                .onEnded { _ in
                    if abs(self.offset.width) > abs(self.offset.height) {
                        if self.offset.width < 0 {
//                            twos.myVar = "left swipe"
                            twos.collapse(dir: .left)
                        } else if self.offset.width > 0{
//                            twos.myVar = "right swipe"
                            twos.collapse(dir: .right)
                        } else {
//                            twos.myVar = "no swipe"
                        }
                    } else if abs(self.offset.width) < abs(self.offset.height) {
                        if self.offset.height < 0 {
//                            twos.myVar = "up swipe"
                            twos.collapse(dir: .up)
                        } else if self.offset.height > 0{
//                            twos.myVar = "down swipe"
                            twos.collapse(dir: .down)
                        } else {
//                            twos.myVar = "no swipe"
                        }
                    } else {
                        self.offset = .zero
                    }
                }
        )
    }
}

struct staticBoardView: View {
    let offsetMulitplier: Int = 75
    var body: some View {
        ZStack {
            ForEach(0..<4) { i in
                ForEach(0..<4) { j in
                    Text("")
                        .frame(width: 70, height: 70, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        .background(Color.gray)
                        .cornerRadius(10)
                        .offset(x: CGFloat(i*offsetMulitplier), y: CGFloat(j*offsetMulitplier))
                }
            }
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var twos : Twos

    var body: some View {

        VStack (spacing: 11){
            scoreView(twos.score)
            ZStack {
                staticBoardView().frame(width: 300, height: 300, alignment: .topLeading)
                boardView(twos.board).environmentObject(twos)
            }
            buttonView().environmentObject(twos)
            toggleView().environmentObject(twos)
        }.alert(isPresented: $twos.isGameOver) {
            Alert(title: Text("Game Over!"),
                  message: Text("Your Final Score is: \(twos.score)"),
                  dismissButton: Alert.Button.default(Text("Start New Game"), action: {
                    twos.newgame(twos.isRandom)
                  }))
        }
    }
}

struct MainView : View {
    @EnvironmentObject var twos : Twos

    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Label("Board", systemImage: "gamecontroller")
                }
                .environmentObject(twos)

            ScoreResultsView()
                .tabItem {
                    Label("Scores", systemImage: "list.dash")
                }
                .environmentObject(twos)
            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle.fill")
                }
                .environmentObject(twos)
        }
    }
}

struct ScoreResultsView : View {
    @EnvironmentObject var twos : Twos
//    @State var size = twos.scores.count

    var body: some View {
        VStack {
            Text("Highest Scores")
                .font(.title)
                .fontWeight(.bold)

            List {
                ForEach(0..<twos.scores.count, id: \.self) { i in
                    Text("\(i+1))\t\t\(twos.getScores()[i].getScore())\t\t\(twos.getScores()[i].getDate())")
                    
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
    }
}

struct AboutView : View {
    @EnvironmentObject var twos : Twos
    @State var size: CGFloat = 0.5
    @State var start: Bool = false
    @State var color: Color = Color.red
    @State var timeLeft = 30
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var hulkSize : CGFloat = 2
    
    @State var xOffset = -150
    @State var xTextOffset = -25
    @State var textColor1 = Color.purple
    @State var textColor2 = Color.clear

    
    var repeatingAnimation: Animation {
        Animation
            .easeIn(duration: 0.5)
//            .spring(dampingFraction:0.5, blendDuration: 1)
//            (duration: 0.5) //.easeIn, .easyOut, .linear, etc...
            .repeatForever()
    }

    var body: some View {
        VStack {
            Text("")
            .onReceive(timer) { _ in
                if timeLeft > 0 && start == true {
                    timeLeft -= 1
                }
                
                if(timeLeft <= 0) {
                    color = Color.green
                    size = hulkSize
                }
            }
            
            ZStack {
            if(start == true) {

                Text("Turning Hulk in 30 Seconds").offset(y: CGFloat(-220))

                
                Circle()
                .frame(width: 200, height: 200, alignment: .center)
                .foregroundColor(color)
                .padding()
                .scaleEffect(size)
                .onAppear() {
                    withAnimation(self.repeatingAnimation) {
                        self.size = 1
                    }
                }
            } else {
                Text("Press Taps to do Stuff").offset(y: CGFloat(-220))

                Circle()
                .frame(width: 200, height: 200, alignment: .center)
                .foregroundColor(.red)
                .padding()
                .scaleEffect(size)
            }
            
            Button(action: {
                    start = true
            }, label: {
                Text("Tap Me")
                    .foregroundColor(.white)
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)

            })
            }
            
            Spacer().frame(width: 10, height: 100, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            
            ZStack {
                Text("Tap to Swipe")
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .foregroundColor(Color.purple)
                    .offset(x: CGFloat(xTextOffset))
                    .animation(/*@START_MENU_TOKEN@*/.easeIn/*@END_MENU_TOKEN@*/(duration: 1))
                
                Button(action: {
                    xOffset *= -1
                    xTextOffset *= -1
                }, label: {
                    Spacer()
                        .frame(width: 250, height: 50, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                })
            }
            
            Circle()
                .frame(width: 350, height: 50)
                .foregroundColor(.yellow)
                .offset(x: CGFloat(xOffset))
                .animation(.easeInOut(duration: 1))
            
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MainView().environmentObject(Twos())
        }
    }
}
