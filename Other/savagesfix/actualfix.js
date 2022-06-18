async function fetchMarketItems() {
    const provider = new ethers.providers.JsonRpcProvider(providerAddress)
    const marketContract = new ethers.Contract(nftmarketaddress, Market.abi, provider)
    // const data = await marketContract.fetchMarketItems()
    let totalSupply = await marketContract.totalSupply()
    totalSupply = totalSupply.toString()
    var traded = 0
    var numItems = 0
    var prices = []
    let found = false
    let classicArtItems = []
    let marketItems = []
    for (var j=0; j < totalSupply; j++) {
      let marketItem = await marketContract.getMarketItem(j+1)
      marketItems.push(marketItem)
    }
    for (var j=0; j < marketItems.length; j++) {
      if (marketItems[j].tokenId.toNumber() > 0 && marketItems[j].listed == true && marketItems[j].nftContract == nftmarketaddress) {
        found = true
        numItems++
        const tokenUri = await marketContract.tokenURI(marketItems[j].tokenId)
        const meta = await axios.get(tokenUri)
        let price = ethers.utils.formatUnits(marketItems[j].price.toString(), 'ether')

        prices.push(price)

        let unix_timestamp = marketItems[j].timeListed.toString()
        //console.log(nftVolume)
        // Create a new JavaScript Date object based on the timestamp
        // multiplied by 1000 so that the argument is in milliseconds, not seconds.
        var date = new Date(unix_timestamp * 1000).toLocaleDateString('en-US')
        let item = {
          time: unix_timestamp,
          date: date,
          itemId: marketItems[j].itemId,
          name: meta.data.name,
          price,
          listed: marketItems[j].listed,
          tokenId: marketItems[j].tokenId.toNumber(),
          seller: marketItems[j].seller,
          owner: marketItems[j].owner,
          image: meta.data.image,
          discription: meta.data.description,
        }

        classicArtItems.push(item)
      }
      if (marketItems[j].nftContract == nftmarketaddress && marketItems[j].timeSold.toString() != 0) {
        let unix_timestamp = marketItems[j].timeSold.toString()
        traded += Number(marketItems[j].sellingPriceOne)
        traded += Number(marketItems[j].sellingPriceTwo)
        traded += Number(marketItems[j].sellingPriceThree)
        traded += Number(marketItems[j].sellingPriceFour)
      }
    }
    setTotalItems(totalSupply)
    if (found) {
      prices.sort((a, b) => a - b)
      setFloorPrice(prices[0])
    }
    setVolumeTraded(ethers.utils.formatUnits(traded.toString(), 'ether'))
    setNumListedItems(numItems)
    setNfts(classicArtItems)
  }