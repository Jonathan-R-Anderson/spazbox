const WebTorrent = require('webtorrent')
const express = require('express')
const app = express()
const client = new WebTorrent()
app.use(express.json())

const torrents = {}

app.post('/add', (req, res) => {
  const magnet = req.body.magnet
  if (!torrents[magnet]) {
    const torrent = client.add(magnet, { path: '/shared/torrents' })
    torrents[magnet] = torrent
    res.send({ status: 'started' })
  } else {
    res.send({ status: 'already downloading' })
  }
})

app.post('/pause', (req, res) => {
  const magnet = req.body.magnet
  if (torrents[magnet]) {
    torrents[magnet].pause()
    res.send({ status: 'paused' })
  } else {
    res.send({ status: 'not found' })
  }
})

app.post('/resume', (req, res) => {
  const magnet = req.body.magnet
  if (torrents[magnet]) {
    torrents[magnet].resume()
    res.send({ status: 'resumed' })
  } else {
    res.send({ status: 'not found' })
  }
})

app.post('/delete', (req, res) => {
  const magnet = req.body.magnet
  if (torrents[magnet]) {
    torrents[magnet].destroy()
    delete torrents[magnet]
    res.send({ status: 'deleted' })
  } else {
    res.send({ status: 'not found' })
  }
})

app.listen(3000, () => console.log('WebTorrent API listening on port 3000'))
