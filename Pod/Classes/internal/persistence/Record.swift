// Record.swift
// RxCache
//
// Copyright (c) 2016 Victor Albertos https://github.com/VictorAlbertos
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

class Record<T : RxObject> : NSObject, NSCoding {
    var source : Source!
    var timeAtWhichWasPersisted : Double!
    var lifeTimeInSeconds: Double!
    var sizeOnMb : Double!
    var rxObjects : [T]!
    private var JSONs = [[String: AnyObject]]()
    
    init(rxObjects : [T], lifeTimeInSeconds: Double) {
        self.source = Source.Memory
        self.rxObjects = rxObjects
        self.timeAtWhichWasPersisted = NSDate().timeIntervalSince1970
        self.lifeTimeInSeconds = lifeTimeInSeconds
    }
    
    //for testing purpose only
    init(source: Source, rxObjects : [T], timeAtWhichWasPersisted: Double, lifeTimeInSeconds: Double) {
        self.source = source
        self.rxObjects = rxObjects
        self.timeAtWhichWasPersisted = timeAtWhichWasPersisted
        self.lifeTimeInSeconds = lifeTimeInSeconds
    }
    
    @objc required init(coder aDecoder: NSCoder) {
        source = Source(rawValue: aDecoder.decodeObjectForKey("source") as! String)
        timeAtWhichWasPersisted = aDecoder.decodeObjectForKey("timeAtWhichWasPersisted") as! Double
        lifeTimeInSeconds = aDecoder.decodeObjectForKey("lifeTimeInSeconds") as! Double
        JSONs = aDecoder.decodeObjectForKey("JSONs") as! [[String: AnyObject]]
        rxObjects = [T]()
        
        for JSON in JSONs {
            let anyObject : AnyObject = T.toSelf(JSON)
            
            if let rxObject = anyObject as? T {
                rxObjects.append(rxObject)
            }
        }
        
        JSONs.removeAll()
    }
    
    @objc func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(source.rawValue, forKey: "source")
        aCoder.encodeObject(timeAtWhichWasPersisted, forKey: "timeAtWhichWasPersisted")
        aCoder.encodeObject(lifeTimeInSeconds, forKey: "lifeTimeInSeconds")
        
        for rxObject in rxObjects {
            JSONs.append(rxObject.toJSON())
        }
        
        aCoder.encodeObject(JSONs, forKey: "JSONs")
    }
}
