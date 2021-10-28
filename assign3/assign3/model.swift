//
//  model.swift
//  assign3
//
//  Created by Simon Liao on 10/14/21.
//

import Foundation

struct Tile: Equatable {
    var val : Int
    var lastRow = 0, lastCol = 0
    var row = 0, col = 0
    var id : Int

    init(_ v: Int, _ newRow: Int, _ newCol: Int, _ newId: Int) {
        val = v
        row = newRow
        col = newCol
        id = newId
    }
}

struct Score: Comparable, Identifiable {
    static func < (lhs: Score, rhs: Score) -> Bool {
        if(lhs.score == rhs.score) {
            return lhs.date > rhs.date
        } else {
            return lhs.score > rhs.score
        }
    }

    var id = Int()
    var score : Int
    var date : Date

    init(_ newScore: Int, _ newDate: Date) {
        score = newScore
        date = newDate
    }

    func getScore() -> Int {
        self.score
    }

    func getDate() -> String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "HH:mm:ss, dd MMM yyyy"
        return dateformatter.string(from: self.date)
    }
}

enum Direction {
    case left
    case right
    case up
    case down
}

// primitive functions

// rotate a square 2D Int array clockwise
public func rotate2DInts(input: [[Int]]) ->[[Int]] {
    var ans: [[Int]] = []
    for j in 0..<4 {
        var temp: [Int] = []
        for i in (0..<4).reversed() {
            temp.append(input[i][j])
        }
        ans.append(temp)
    }
    return ans
}

// generic version of the above
public func rotate2D<T>(input: [[T]]) ->[[T]] {
    var ans: [[T]] = []
    for j in 0..<4 {
        var temp: [T] = []
        for i in (0..<4).reversed() {
            temp.append(input[i][j])
        }
        ans.append(temp)
    }
    return ans
}

class Twos : ObservableObject {
    // must be init'd, but contents overwritten
    @Published var board : [Tile]
    @Published var internalBoard : [[Tile]]
    @Published var score : Int = 0 //I set it to default as 0 first
    @Published var isRandom : Bool = true
    @Published var isGameOver : Bool = false
    @Published var scores : [Score]
    private var localIsRandom : Bool = true
    
    private var determNumGenerator : SeededGenerator
    private var randomNumGenerator : SystemRandomNumberGenerator
    private var spacesRemoved : Bool = false
    private var mergesOccured : Bool = false


    //my init
    init() {
        //seed number generators
        randomNumGenerator = SystemRandomNumberGenerator()
        determNumGenerator = SeededGenerator(seed: UInt64(Int.random(in:1...1000)))

        //just starting it off with all 0s
        board = []
        internalBoard = []
        scores = [Score(400, Date()), Score(300, Date())]
        
        var counter = 0
        for i in 0..<4 {
            for j in 0..<4 {
                board.append(Tile(0, i, j, counter))
                counter += 1
            }
        }
        
        //init internal board by making a 2D arry of tiles, this is just a place holder
        internalBoard = []
        internalBoard.append([Tile(0, 0, 0, 0), Tile(0, 0, 0, 0), Tile(0, 0, 0, 0), Tile(0, 0, 0, 0)])
        internalBoard.append([Tile(0, 0, 0, 0), Tile(0, 0, 0, 0), Tile(0, 0, 0, 0), Tile(0, 0, 0, 0)])
        internalBoard.append([Tile(0, 0, 0, 0), Tile(0, 0, 0, 0), Tile(0, 0, 0, 0), Tile(0, 0, 0, 0)])
        internalBoard.append([Tile(0, 0, 0, 0), Tile(0, 0, 0, 0), Tile(0, 0, 0, 0), Tile(0, 0, 0, 0)])
        
    }

    func initBoard() {
        //clear board
        board = []
        
        //internal board should just remain with the same data because its going to change anyways
        var counter = 0
        for i in 0..<4 {
            for j in 0..<4 {
                board.append(Tile(0, i, j, counter))
                counter += 1
            }
        }
    }

    func setScore(_ newScore : Int) {
        score = newScore
    }
    
    func addScore() {
        //add
        scores.append(Score(score, Date()))

        //sort
        scores.sort()
    }

    func getScores() -> [Score] {
        scores
    }

    //Assign 2 added functions
    func newgame(_ rand: Bool) {
        //add score
        addScore()
        
        //reset score
        score = 0

        //create new empty board
        initBoard()

        //set the random flag
        localIsRandom = rand
        
        startEdits()
        //decide which generator to user
        if(rand) {
            randomNumGenerator = SystemRandomNumberGenerator()
            spawn()
            spawn()
        } else {
            determNumGenerator = SeededGenerator(seed: 14)
            spawn()
            spawn()
        }
        stopEdits()
        
        isGameOver = false
    }

    func spawn() {
        //scanning for open spaces
        var openTilesByRowAndCol : [(Int, Int)] = []
        for i in 0..<4{
            for j in 0..<4 {
                if internalBoard[i][j].val == 0 {
                    openTilesByRowAndCol.append((i, j))
                }
            }
        }

        //randomly choose one
        if(localIsRandom) {
            //decide new val
            let newVal = Int.random(in: 1...2, using: &randomNumGenerator) * 2

            //decide new location
            let randIndex = Int.random(in: 0..<openTilesByRowAndCol.count, using: &randomNumGenerator)
            self.internalBoard[openTilesByRowAndCol[randIndex].0][openTilesByRowAndCol[randIndex].1].val = newVal
        } else {
            //decide new val
            let newVal = Int.random(in: 1...2, using: &determNumGenerator) * 2

            //decide new location
            let randIndex = Int.random(in: 0..<openTilesByRowAndCol.count, using: &determNumGenerator)
            self.internalBoard[openTilesByRowAndCol[randIndex].0][openTilesByRowAndCol[randIndex].1].val = newVal
        }
    }

    func swapTiles(_ row1: Int, _ col1: Int, _ row2: Int, _ col2: Int) {
        //swapping indecies in board
        let tempRow = internalBoard[row1][col1].row
        let tempCol = internalBoard[row1][col1].col

        //swap row and col variableand val
        self.internalBoard[row1][col1].row = self.internalBoard[row2][col2].row
        self.internalBoard[row1][col1].col = self.internalBoard[row2][col2].col

        self.internalBoard[row2][col2].row = tempRow
        self.internalBoard[row2][col2].col = tempCol

        let temp: Tile = internalBoard[row1][col1]
        internalBoard[row1][col1] = internalBoard[row2][col2]
        internalBoard[row2][col2] = temp
    }

    // high-level functions
    func merge() -> Bool {
        var mergesOccured = false
        for i in 0..<4 {
            for j in 0..<3 {
                if self.internalBoard[i][j].val == self.internalBoard[i][j+1].val && self.internalBoard[i][j].val != 0 {
                    self.internalBoard[i][j+1].val *= 2
                    score += self.internalBoard[i][j+1].val
                    self.internalBoard[i][j].val = 0
                    
                    swapTiles(i, j, i, j+1)
                    
                    mergesOccured = true
                }
            }
        }
        return mergesOccured
    }

    func removeSpaces() -> Bool {
        var emptySpaceFound = false
        for i in 0..<4 {
            var left = 0
            var right = 1
            while right < 4 {
                if internalBoard[i][left].val == 0 {
                    if internalBoard[i][right].val > 0 {
                        swapTiles(i, left, i, right)
                        left += 1
                        emptySpaceFound = true
                    }
                    right += 1
                } else {
                    left += 1
                    if right == left {
                        right = left+1
                    }
                }
            }
        }
        return emptySpaceFound
    }

    func stillAbleToMove() -> Bool {
        //check every tile except last row and last col
        for i in 0...2 {
            for j in 0...2 {
                if internalBoard[i][j].val == internalBoard[i][j+1].val || internalBoard[i][j].val == internalBoard[i+1][j].val || internalBoard[i][j].val == 0 {
                    return true
                }
            }
        }
        
        //check every tile inside last row and last col
        for i in 0...2 {
            if(internalBoard[3][i].val == internalBoard[3][i+1].val || internalBoard[i][3].val == internalBoard[i+1][3].val || internalBoard[3][i].val == 0 || internalBoard[i][3].val == 0) {
                return true
            }
        }
        
        //check bottom right tile
        if(internalBoard[3][3].val == 0) {
            return true
        }

        return false
    }

    // collapse to the left
    func shiftLeft() {
        spacesRemoved = removeSpaces()
        mergesOccured = merge()
        removeSpaces()

        //scanning for open spaces
        var tilesOpen = false
        for i in 0..<16 {
            if board[i].val == 0 {
                tilesOpen = true
                break
            }
        }

        if !tilesOpen {
            if(!stillAbleToMove()) {
                isGameOver = true
                return
            }
        }
    }

    // define using only rotate2D
    func rightRotate() {
        self.internalBoard = rotate2D(input: self.internalBoard)
    }

    func doSpawnIfNeeded() {
        if mergesOccured || spacesRemoved {
            spawn()
        }
        mergesOccured = false
        spacesRemoved = false
    }

    func testing() {
        swapTiles(0, 0, 1, 1)
    }

    //MUST be run before starting any operation on the board
    func startEdits() {
        //at this point, it is assumed that internalboard has initalized all indecies
        
        //copy over board tiles in correct index in internal board
        for i in 0..<16 {
            internalBoard[board[i].row][board[i].col] = board[i]
        }
    }
    
    //MUST be run in order to save edits on the board
    func stopEdits() {
        for i in 0..<4 {
            for j in 0..<4 {
                board[internalBoard[i][j].id].row = internalBoard[i][j].row
                board[internalBoard[i][j].id].col = internalBoard[i][j].col
                board[internalBoard[i][j].id].val = internalBoard[i][j].val
            }
        }
    }
    
    // collapse in direction "dir"
    func collapse(dir: Direction) -> Bool {
        
        startEdits()
        switch dir {
        case .left:
            shiftLeft()
        case .up:
            rightRotate()
            rightRotate()
            rightRotate()
            shiftLeft()
            rightRotate()
        case .right:
            rightRotate()
            rightRotate()
            shiftLeft()
            rightRotate()
            rightRotate()
        case .down:
            rightRotate()
            shiftLeft()
            rightRotate()
            rightRotate()
            rightRotate()
        default:
            return false
        }
        
        doSpawnIfNeeded()
        stopEdits()
        
        //cehck if game is over
        if !stillAbleToMove() {
            isGameOver = true
        }
        
        return true
    }


}
