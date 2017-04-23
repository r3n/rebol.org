REBOL [
   File: %arff-datamining.r
   Date: 31-Jan-2009
   Title: {ARFF Data Mining}
   Author: {Izkata}
   Email: Izkata@gmail.com
   Purpose: {
      Implement a framework for Data Mining algorithms that works on ARFF files.
      Includes various algorithms.  Assumes class being mined for is the last attribute.
   }
   Library: [
      level: 'advanced
      platform: 'all
      type: [package tool]
      domain: [ai file-handling math scientific testing]
   ]
   Tested-Under: [
      [ {Windows}     2.7.6 ]
      [ {Ubuntu 8.04} 2.7.6 ]
   ]
   History: [
      25-Jan-2009 thru 22-Feb-2009 {Initial creation and recreation to this version}
      29-Jan-2009 thru 19-Feb-2009 {Replace Missing Values, Entropy-Based Discretizers, and Naïve Bayes}
      19-Feb-2009 thru 12-Mar-2009 {Decision Tree (Currently incomplete, but works)}
   ]
   Info: {
      Preprocessing
         Replace Missing Values
            Average by class for continuous, most common by class for categorical
         Transform
            Categorical -> Continuous by category index
            Continuous -> Categorical by an entropy-based discretizer that works by combining groups
                          (Much faster, but less accurate than, splitting the standard way)
            Categorical -> Ordinal, indicated by storing the attributes internally as words
                           (Categorical is stored internally as strings)
            Continuous -> Ordinal not supported, but would be a simple fix
            

      Data Mining Algorithms
         Naïve Bayes
            Probabilities based on counting up the training data
         Decision Tree
            A tree of (most) possible outcomes, limited by and based on the training data

      Up-And-Coming
         Normalization: Min/Max
         Normalization: Z-Score
         Data Mining Algorithm: Neural Network

      Possibly Up-And-Coming
         Data Mining Algorithm: Clustering
         Data Mining Algorithm: Association Rule
   }
   Background: {
      Spring 2009 semester, I'm taking a Data Mining course.  Everyone I've ever asked about it has
         said something along the lines of "The semester you take it will be hell.  But if you can
         get through it, you will feel like a programming god."

      Come the first day of class, a nice surprise came:  Our professor doesn't care what langauge
         we use, as long as we provide a Windows batch file she can double-click on to run it.

      The result is this.  The package will be updated throughout this semester.
   }
]

print {This is only a stub.  The entirety needs to be installed with the Rebol.org package manager.}
print {Loading package manager now - select arff-datamining.r from the list}
wait 1
do http://www.rebol.org/library/public/repack.r
