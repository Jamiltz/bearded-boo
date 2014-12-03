// Playground - noun: a place where people can play

import UIKit

var url = NSURL(string: "http://youtube.com/watch?v=12345832u3299230")
let queryString = url!.query!
let sub = queryString[advance(queryString.startIndex, 2)...advance(queryString.startIndex, 10)]

var arr = [["start": 4], ["start": 1], ["start": 3]]
arr.sort({ return $0["start"] < $1["start"] })
arr

let string = "http://r7---sn-cu-aigz.googlevideo.com/videoplayback?initcwndbps=1951250&mm=31&sver=3&id=o-AIMvU2i8is23jx_2u5Ocli8nwGvjwXi7MnnHOaGgElnf&mt=1416701229&ratebypass=yes&mv=m&source=youtube&ms=au&ip=86.164.98.204&itag=18&signature=CB8FF639AC88C706838A16DD09D058B253D7A13D.4FD890DAE6DF0BE453DF79F63455E43F690FF32C&ipbits=0&upn=LktaEOYifSU&expire=1416722930&fexp=907259%2C913587%2C916640%2C927622%2C931345%2C932404%2C939977%2C943909%2C945816%2C947209%2C947215%2C948124%2C952302%2C952605%2C952901%2C953912%2C954202%2C957103%2C957105%2C957201&key=yt5&sparams=id%2Cinitcwndbps%2Cip%2Cipbits%2Citag%2Cmm%2Cms%2Cmv%2Cratebypass%2Csource%2Cupn%2Cexpire&TVBcEg6klJI"

let count = countElements(string)
let sub2 = string[advance(string.startIndex, count - 11)...advance(string.startIndex, count - 1)]
sub2

var dict = ["james": 23, "luka": 12, "oliver": 16]
dict.count

var str3 = "1dqw"
str3[advance(str3.startIndex, 0)...advance(str3.startIndex, 3)]

extension String {
    func MD5() {
        
    }
}