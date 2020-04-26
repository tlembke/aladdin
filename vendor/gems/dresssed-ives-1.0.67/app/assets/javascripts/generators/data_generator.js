var DataGenerator = function(dataPointCount, startingValue) {
  this.dataPointCount = dataPointCount;
  this.dataSet        = [];
  this.startingValue  = startingValue || 40;
}

DataGenerator.prototype.getRandomizedData = function() {
  if (this.dataSet.length > 0) {
      this.dataSet = this.dataSet.slice(1);
    }

    while (this.dataSet.length < this.dataPointCount) {
      var lastYCoord = this.dataSet.length > 0 ? this.dataSet[this.dataSet.length - 1] : this.startingValue,
          newYCoord = lastYCoord + Math.random() * 8 - 4;
      newYCoord = Math.min(Math.max(newYCoord, 0), 100);
      this.dataSet.push(newYCoord);
    }

    var res = [];
    for (var i = 0; i < this.dataSet.length; ++i) {
      res.push([i, this.dataSet[i]])
    }

    return res;
}