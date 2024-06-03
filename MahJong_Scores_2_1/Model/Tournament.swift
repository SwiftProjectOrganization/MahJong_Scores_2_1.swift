//
//  Tournament.swift
//  MJ Scores
//
//  Created by Robert Goedman on 3/24/24.
//
//

import Foundation
import SwiftUI
import SwiftData

@Model
public class Tournament {

  // Tournament wide settings, currently not used
  
  var rotateClockwise: Bool?
  var ruleSet: String?
  let startDate: String?
  
  // Tournament wide values
  var scheduleItem: Int = 0
  var lastGame: Int?
  
  // Player names and sequence when tournament is started
  var fpName: String?
  var spName: String?
  var tpName: String?
  var lpName: String?
  
  // Game values
  var windPlayer: String?
  var currentWind: String?
  var players: [String]?
  var winds: [String]?
  var gameWinnerName: String?

  var ptScore: [String: Int]?
  var pgScore: [String: Int]?
  var windsToPlayersInGame: [String: String]?
  var playersToWindsInGame: [String: String]?

  @Relationship(deleteRule: .cascade,
                inverse: \Score.tournament)
  var fpScores: [Score]?
  
  @Relationship(deleteRule: .cascade,
                inverse: \Score.tournament)
  var spScores: [Score]?
  
  @Relationship(deleteRule: .cascade,
                inverse: \Score.tournament)
  var tpScores: [Score]?
  
  @Relationship(deleteRule: .cascade,
                inverse: \Score.tournament)
  var lpScores: [Score]?
  
  init(_ fpName: String,
       _ spName: String,
       _ tpName: String,
       _ lpName: String,
       _ windPlayer: String,
       _ currentWind: String,
       _ gameWinnerName: String) {
    self.rotateClockwise = true
    self.ruleSet = "INTERNATIONAL"
    self.startDate = dateToString()
    self.lastGame = -1
    self.fpName = fpName
    self.spName = spName
    self.tpName = tpName
    self.lpName = lpName
    self.windPlayer = windPlayer
    self.currentWind = currentWind
    self.gameWinnerName = gameWinnerName
    self.fpScores = []
    self.spScores = []
    self.tpScores = []
    self.lpScores = []
  }
}

extension Tournament {
    var title: String {
      "\(self.ruleSet!) tournament: \(currentWind!) \n \(startDate!):\(fpName!) \(spName!) \(tpName!) \(lpName!)"
    }
}

extension Tournament {
    var titleArray: Array<String> {
      [currentWind!, startDate!, fpName!, spName!, tpName!, lpName!]
    }
}

extension Tournament {
  var sortedFpScores: [Score] {
    let scores = self.fpScores!.filter { $0.tournament! == self }
    let sortedScores = scores.sorted {$0.game! < $1.game!}
    return sortedScores
  }
}

extension Tournament {
  var sortedSpScores: [Score] {
    let scores = self.spScores!.filter { $0.tournament! == self }
    let sortedScores = scores.sorted {$0.game! < $1.game!}
    return sortedScores
  }
}

extension Tournament {
  var sortedTpScores: [Score] {
    let scores = self.tpScores!.filter { $0.tournament! == self }
    let sortedScores = scores.sorted {$0.game! < $1.game!}
    return sortedScores
  }
}

extension Tournament {
  var sortedLpScores: [Score] {
    let scores = self.lpScores!.filter { $0.tournament! == self }
    let sortedScores = scores.sorted {$0.game! < $1.game!}
    return sortedScores
  }
}

extension Tournament {
  func rotateStringArray(_ stringArray: Array<String>, _ steps: Int = 1) -> Array<String> {
    var p = stringArray
    for _ in 1...steps {
      let tmp = p[0]
      p[0] = p[1]
      p[1] = p[2]
      p[2] = p[3]
      p[3] = tmp
    }
    return p
  }
}

extension Tournament {
  func windsAndPlayers(_ winds: Array<String>, _ players: Array<String>, _ item:Int) -> (Array<String>, Array<String>) {
    var w = winds
    var p = players
    if item > 0 {
      if item % 4 == 0 {
        p = rotateStringArray(p, 2)
        w = rotateStringArray(w, 1)
      } else {
        p = rotateStringArray(p, 1)
      }
    }
    return (w, p)
  }
}

extension Tournament {
  func updateTournamentStatus() {
    if self.scheduleItem < (self.ruleSet! == "Traditional" ? 16 : 4) {
      //
      // Generate the state of the tournament based on scheduleItem
      //
      // If scheduleItem == 0
      // tmp = (["East", "South", "West", "North"], ["Liesbeth", "Rob", "Nancy", "Carel"])
      // If scheduleItem == 1
      // tmp = [["East", "South", "West", "North"], [["Rob", "Nancy", "Carel", "Liesbeth"]]
      // ...
      // If scheduleItem == 4:
      // tmp = (["South", "West", "North", "East"], ["Rob", "Nancy", "Carel", "Liesbeth"])
      // ...
      //
      // (7, (["South", "West", "North", "East"], ["Liesbeth", "Rob", "Nancy", "Carel"]))
      // (8, (["West", "North", "East", "South"], ["Nancy", "Carel", "Liesbeth", "Rob"]))
      // (9, (["West", "North", "East", "South"], ["Carel", "Liesbeth", "Rob", "Nancy"]))
      //
      // Until scheduleItem == 16, at which point the tournament is "Done".
      //
      let tmp = self.windsAndPlayers(self.winds!, self.players!, self.scheduleItem)
      //print((self.scheduleItem, tmp))
      self.windsToPlayersInGame = Dictionary(uniqueKeysWithValues: zip(tmp.0, tmp.1))
      self.playersToWindsInGame = Dictionary(uniqueKeysWithValues: zip(tmp.1, tmp.0))
      self.currentWind = tmp.0[0]
      self.windPlayer = tmp.1[0]
      self.winds = tmp.0
      self.players = tmp.1
    } else {
      self.currentWind = "Done"
    }
  }
}

extension Tournament {
  func updateGameScores() {
    self.fpScores!.append(Score(self.fpName!, self.lastGame!, self.ptScore![self.fpName!]!))
    self.spScores!.append(Score(self.spName!, self.lastGame!, self.ptScore![self.spName!]!))
    self.tpScores!.append(Score(self.tpName!, self.lastGame!, self.ptScore![self.tpName!]!))
    self.lpScores!.append(Score(self.lpName!, self.lastGame!, self.ptScore![self.lpName!]!))
  }
}
