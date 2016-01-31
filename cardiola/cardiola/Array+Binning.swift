//
//  Array+Binning.swift
//  cardiola
//
//  Created by Janusch Jacoby on 31/01/16.
//  Copyright © 2016 BPPolze. All rights reserved.
//

extension Array {
    
    internal typealias ComparisonFunction = (Element, Element) -> Bool
    
    /**
     Collects all elements considered similar into separate bins.

     - parameter sort:     function to sort the elements in the array
     - parameter similar:  function to determine whether to elements fit into the same bin
     
     - returns: two-dimensional array of bins containing the fitted elements
     */
    func collectSimilar(sort: ComparisonFunction, similar: ComparisonFunction) -> [[Element]]
    {
        guard self.count > 0 else {
            return [[Element]]()
        }
        var results: [[Element]] = [[Element]()]
        let sortedElements = self.sort(sort)
        var last = sortedElements[0]
        for element in sortedElements {
            if !similar(last, element) {
                results.append([Element]())
            }
            results[results.count - 1].append(element)
            last = element
        }
        return results
    }

    /**
     Collect all elements considered equal into separate bins.
     
     - parameter project: function mapping to the attribute of a complex object used for binning
     
     - returns: two-dimensional array of bins containing the fitted elements
     */
    func collectEquals<T: Any where T: Equatable, T: Comparable>(project: (Element) -> T) -> [[Element]]
    {
        let sort: ComparisonFunction = { project($0) < project($1) }
        let similar: ComparisonFunction = { project($0) == project($1) }
        return self.collectSimilar(sort, similar: similar)
    }

}