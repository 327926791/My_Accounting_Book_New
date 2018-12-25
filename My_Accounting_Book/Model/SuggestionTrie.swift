//
//  SuggestionTrie.swift
//  My_Accounting_Book
//
//  Created by Chi Zhang on 2018/11/26.
//  Copyright © 2018年 Team_927. All rights reserved.
//

import Foundation

let AMOUNT_TRIE = 0
let LOCATION_TRIE = 1

class WordAndCount {
    var word: String
    var count: UInt
    var fscore: Int
    init(word: String, count: UInt, fs: Int) {
        self.word = word
        self.count = count
        self.fscore = fs
    }
}

class TrieNode {
    var links: Array<TrieNode?>
    var validLinkIndexList: [Int]
    var wordAndCountList: [WordAndCount]
    var type: Int
    
    init(type: Int) {
        if type == AMOUNT_TRIE {
            links = Array(repeating: nil, count: 11)
            self.type = AMOUNT_TRIE
        }
        else {
            links = Array(repeating: nil, count: 36)
            self.type = LOCATION_TRIE
        }
        validLinkIndexList = []
        wordAndCountList = []
    }
    
    func get(ch: Character) -> TrieNode? {
        if ch.ascii == nil {
            return nil
        }
        var index = Int(ch.ascii!)
        if type == AMOUNT_TRIE {
            // Decimal digit
            if Helpers.asciiIsDecimalDigit(a: index) {
                return links[index - 48]
            }
                // Decimal point
            else {
                return links[10]
            }
        }
        else {
            // Decimal digit
            if Helpers.asciiIsDecimalDigit(a: index) {
                return links[index - 48 + 26]
            }
                // Lower case letter
            else {
                if Helpers.asciiIsUpperCaseLetter(a: index) {
                    index += 32
                }
                return links[index - 97]
            }
        }
    }
    func put(ch: Character, node: TrieNode) {
        if ch.ascii == nil {
            return
        }
        var index = Int(ch.ascii!)
        if type == AMOUNT_TRIE {
            // Decimal digit
            if Helpers.asciiIsDecimalDigit(a: index) {
                links[index - 48] = node
                validLinkIndexList.append(index - 48)
            }
                // Decimal point
            else {
                links[10] = node
                validLinkIndexList.append(10)
            }
        }
        else {
            // Decimal digit
            if Helpers.asciiIsDecimalDigit(a: index) {
                links[index - 48 + 26] = node
                validLinkIndexList.append(index - 48 + 26)
            }
                // Lower case letter
            else {
                if Helpers.asciiIsUpperCaseLetter(a: index) {
                    index += 32
                }
                links[index - 97] = node
                validLinkIndexList.append(index - 97)
            }
        }
    }
    // To be implemented: remove
}

class SuggestionTrie {
    private var root: TrieNode
    private var trieType: Int
    
    init(trieType: Int) {
        root = TrieNode(type: trieType)
        self.trieType = trieType
    }
    
    // Insert a word if it not exists
    // Increase the word count if it already existed
    func insert(word: String) {
        var node = root
        for i in word.unicodeScalars {
            if !Helpers.usIsValid(u: i, t: trieType) {
                continue
            }
            let char = Character(i)
            if node.get(ch: char) == nil {
                node.put(ch: char, node: TrieNode(type: trieType))
            }
            if node.get(ch: char) == nil {
                return
            }
            node = node.get(ch: char)!
        }
        if node !== root {
            if node.wordAndCountList.count == 0 {
                node.wordAndCountList.append(WordAndCount(word: word, count: 1, fs: 1))
            }
            else {
                for i in 0..<node.wordAndCountList.count {
                    if (word == node.wordAndCountList[i].word) {
                        node.wordAndCountList[i].count += 1
                        return
                    }
                }
                node.wordAndCountList.append(WordAndCount(word: word, count: 1, fs: 1))
            }
        }
    }
    
    func traverse(node: TrieNode, words: inout [WordAndCount]) {
        if node.wordAndCountList.count > 0 {
            for i in 0..<node.wordAndCountList.count {
                words.append(node.wordAndCountList[i])
            }
        }
        for i in node.validLinkIndexList {
            traverse(node: node.links[i]!, words: &words)
        }
    }
    
    // ret == true -> prefix is contained in trie
    // ret == false -> prefix is partially contained or not contained in trie -> fuzzy search is needed
    func retrieve(prefix: String, words: inout [WordAndCount]) -> Bool {
        var node = root
        var contained = true
        for i in prefix.unicodeScalars {
            if !Helpers.usIsValid(u: i, t: trieType) {
                continue
            }
            let char = Character(i)
            if node.get(ch: char) == nil {
                contained = false
                break
            }
            node = node.get(ch: char)!
        }
        traverse(node: node, words: &words)
        return contained
    }
    
    // Remove the word if its count was 1
    // Decrease the word count by 1 if its count was greater than 1
    func remove(word: String) {
        var node = root
        for i in word.unicodeScalars {
            if !Helpers.usIsValid(u: i, t: trieType) {
                continue
            }
            let char = Character(i)
            if node.get(ch: char) == nil {
                return
            }
            node = node.get(ch: char)!
        }
        if node !== root {
            for i in 0..<node.wordAndCountList.count {
                if (word == node.wordAndCountList[i].word) {
                    if (node.wordAndCountList[i].count > 1) {
                        node.wordAndCountList[i].count -= 1
                    }
                    else {
                        node.wordAndCountList.remove(at: i)
                    }
                    return
                }
            }
        }
    }
}

class Helpers {
    static func usIsValid(u: UnicodeScalar, t: Int) -> Bool {
        if t == AMOUNT_TRIE {
            return (String(u) == ".") || CharacterSet.decimalDigits.contains(u)
        }
        else {
            return CharacterSet.letters.contains(u) || CharacterSet.decimalDigits.contains(u)
        }
    }
    
    static func asciiIsDecimalPoint(a: Int) -> Bool {
        return a == 46
    }
    
    static func asciiIsDecimalDigit(a: Int) -> Bool {
        return a >= 48 && a <= 57
    }
    
    static func asciiIsUpperCaseLetter(a: Int) -> Bool {
        return a >= 65 && a <= 90
    }
    
    static func asciiIsLowerCaseLetter(a: Int) -> Bool {
        return a >= 97 && a <= 122
    }
}
