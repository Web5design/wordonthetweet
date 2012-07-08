fs = require('fs')

learnData = (input, output, cutoff) ->
  console.log "-Learning", input
  fs.readFile input, 'utf8', (err, data) ->
    tweets = JSON.parse data
    labeled = new NaiveBayesClassifier()

    for t in tweets
      t = new Tweet({'text': t.t, 'sentiment': t.s})
      labeled.train(t)
    labeled.outputData (data) -> 
      console.log "-Writing", output
      for s, a of data['featureCount']
          data['featureCount'][s] = (f: v for f, v of a when v > cutoff)
      json = JSON.stringify data
      fs.writeFile output, json, (err, data) ->
        console.log "-done with", input, "->", output

fixAfinn = () ->
  fs.readFile 'raw_data/afinn-111-emo.json', 'utf8', (err, data) ->
    doubleLetter = /([a-z])\1+/g
    output = {}
    for w, v of JSON.parse data
      w = w.replace doubleLetter, "$1"
      output[w] = v
    json = JSON.stringify output
    fs.writeFile 'data/afinn-111-emo.json', json, (err, data) ->
      console.log "-done with afinn"


learnData 'raw_data/labeled.json', 'data/labeled.json', 0
learnData 'raw_data/emoticon.json', 'data/emoticon.json', 1
fixAfinn()