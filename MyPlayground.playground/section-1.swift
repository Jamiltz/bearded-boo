// Playground - noun: a place where people can play

import UIKit

var url = NSURL(string: "http://youtube.com/watch?v=12345832u3299230")
let queryString = url!.query!
let sub = queryString[advance(queryString.startIndex, 2)...advance(queryString.startIndex, 10)]

var arr = [["start": 4], ["start": 1], ["start": 3]]
arr.sort({ return $0["start"] < $1["start"] })
arr
