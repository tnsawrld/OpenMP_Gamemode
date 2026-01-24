#define CHANEL_REQ "1452865547229331537"

DCMD:test(user, channel, params[]) {
    if(channel != DCC_FindChannelById(CHANEL_REQ))
        return DCC_SendChannelMessage(channel, "**[BOT]** :x: kamu tidak dichannel yang tepat!");
    new DCC_Embed:testingembed = DCC_CreateEmbed(.title = "Test title", .footer_text = "footer test");
    DCC_SetEmbedDescription(testingembed, "Ini baru ya pepek");
    DCC_SetEmbedColor(testingembed, 0x0044FFFF);
    DCC_SendChannelEmbedMessage(channel, testingembed);
    return 1;
}