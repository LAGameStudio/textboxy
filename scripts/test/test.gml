tby_init();

var c = new TbyChain([
    new TbyChunk().add.box("testo texto", "top"),
    new TbyChunk().add.box("123", "top"),
    new TbyChunk().add.pause(1),
    new TbyChunk().add.box("hiu", "top"),
]);

var d = new TbyChain([
    new TbyChunk().add.box("tkkkkkkkkkkkkkkkkkko", "middle"),
]);

//c.run();
c.run();

//var t = new TbySpeechBubble(10, 10, "testbubble", noone);