from flask import Flask
from web3 import Web3
import requests, os

app = Flask(__name__)
webtorrent_api = os.getenv("WEBTORRENT_API", "http://webtorrent:3000")

# Connect to zkSync
w3 = Web3(Web3.HTTPProvider("https://zksync2-testnet.zksync.dev"))
contract_address = Web3.to_checksum_address(os.getenv("CONTRACT_ADDRESS"))
with open("abi.json") as f:
    abi = json.load(f)
contract = w3.eth.contract(address=contract_address, abi=abi)

def handle_event(event):
    evt = event.event
    magnet = event.args["magnetURI"]
    print(f"Event: {evt} - {magnet}")

    if evt == "TorrentAdded":
        requests.post(f"{webtorrent_api}/add", json={"magnet": magnet})
    elif evt == "TorrentPaused":
        requests.post(f"{webtorrent_api}/pause", json={"magnet": magnet})
    elif evt == "TorrentResumed":
        requests.post(f"{webtorrent_api}/resume", json={"magnet": magnet})
    elif evt == "TorrentDeleted":
        requests.post(f"{webtorrent_api}/delete", json={"magnet": magnet})

def monitor_contract():
    event_filter = contract.events.TorrentAdded.create_filter(fromBlock="latest")
    while True:
        for e in event_filter.get_new_entries():
            handle_event(e)

if __name__ == "__main__":
    import threading
    threading.Thread(target=monitor_contract).start()
    app.run(host="0.0.0.0", port=5000)
