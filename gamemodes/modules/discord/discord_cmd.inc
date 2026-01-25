#define CHANNEL_UCP "1452865547229331537"
#define GUILD_ID "1452308565682421840"
#define ROLE_ID "1454449144658792520"

DCMD:test(user, channel, params[]) {
    if(channel != DCC_FindChannelById(CHANNEL_UCP))
        return DCC_SendChannelMessage(channel, "**[BOT]** :x: kamu tidak dichannel yang tepat!");
    new DCC_Embed:testingembed = DCC_CreateEmbed(.title = "Test title", .footer_text = "footer test");
    DCC_SetEmbedDescription(testingembed, "Ini baru ya pepek");
    DCC_SetEmbedColor(testingembed, 0x0044FFFF);
    DCC_SendChannelEmbedMessage(channel, testingembed);
    return 1;
}

DCMD:createucp(user, channel, params[])
{
    new name[128],
        userID[21];


    if(channel != DCC_FindChannelById(CHANNEL_UCP))
        return 1;

    if(sscanf(params, "s[128]", name))
        return DCC_SendChannelMessage(channel, "**[USAGE]** !createucp <nama ucp>");

    DCC_GetUserId(user, userID, sizeof(userID));
    
    new dquery[128];
    mysql_format(g_SQL, dquery, sizeof(dquery), "SELECT ucp_name FROM ucp WHERE discord_id = '%e' LIMIT 1", userID);
    mysql_tquery(g_SQL, dquery, "OnDiscordIDChecked", "ss", name, userID);
    printf("Discord id %s", userID);
    return 1;
}

Function::OnDiscordIDChecked(const name[], const discord_id[])
{
    new tempUCP[24];
    new DCC_Channel:channel_register = DCC_FindChannelById(CHANNEL_UCP);
    printf("Discord id %s", discord_id);
    printf("name is %s", name);
    if(cache_num_rows())
    {
        cache_get_value_name(0, "ucp_name", tempUCP);

        new str[200];
        format(str, sizeof(str), "**[BOT]** Kamu pernah mendaftarkan akun UCP sebelumnya dengan nama _%s_!", tempUCP);
        return DCC_SendChannelMessage(channel_register, str);
    }
    else
    {
        new dquery[128];
        mysql_format(g_SQL, dquery, sizeof(dquery), "SELECT * FROM ucp WHERE ucp_name = '%e' LIMIT 1", name);
        mysql_tquery(g_SQL, dquery, "OnDiscordUCPNameChecked", "ss", name, discord_id);
    }
    return 1;
}

Function::OnDiscordUCPNameChecked(const name[], const discord_id[])
{
    new verifyCode = RandomEx(111111, 999999);
    new DCC_Channel:channel_register = DCC_FindChannelById(CHANNEL_UCP);
    printf("Discord id %s", discord_id);
    printf("name is %s", name);
    printf("verify %d", verifyCode);
    if(cache_num_rows())
    {
        return DCC_SendChannelMessage(channel_register, "**[BOT]** Nama UCP tersebut sudah dipakai oleh orang lain!");
    }
    else
    {
        new formatName[30];
        format(formatName, sizeof(formatName), "MEMBER | %s", name);

        new DCC_Guild:guildID = DCC_FindGuildById(GUILD_ID);
        new DCC_Role:roleID = DCC_FindRoleById(ROLE_ID);
        new DCC_User:userID = DCC_FindUserById(discord_id);

        DCC_SetGuildMemberNickname(guildID, userID, formatName);
        DCC_AddGuildMemberRole(guildID, userID, roleID);
        DCC_SendChannelMessage(channel_register, "**[BOT]** UCP berhasil didaftarkan! Silahkan tunggu DM dari bot");
        DCC_CreatePrivateChannel(userID, "OnDirectMessageUCP", "sds", name, verifyCode, discord_id);

    }
    return 1;
}

Function::OnDirectMessageUCP(const name[], verify_code, const discord_id[])
{
    printf("Discord id %s", discord_id);
    printf("name is %s", name);
    printf("verify %d", verify_code);

    new DCC_Channel:Private = DCC_GetCreatedPrivateChannel();

    new DCC_Embed:embedUCP = DCC_CreateEmbed(.title = "Basic Roleplay", .footer_text = "Akun UCP anda berhasil terdaftar!");

    new str[200];
    format(str, sizeof(str), "Gunakan verify code untuk memverifikasi bahwa ini akun anda (in-game)\
    \n** UCP : ** \n```%s```\
    \n** Discord ID : ** \n```%s```\
    \n** Verify Code : ** \n ```%d```", name, discord_id, verify_code);

    DCC_SetEmbedDescription(embedUCP, str);
    DCC_SetEmbedColor(embedUCP, 0x0000EDFF);
    DCC_SendChannelEmbedMessage(DCC_Channel:Private, embedUCP);

    new dquery[350];
    mysql_format(g_SQL, dquery, sizeof(dquery), "INSERT INTO ucp (ucp_name, discord_id, verifycode) VALUES ('%e', '%e', '%d')", name, discord_id, verify_code);
    mysql_tquery(g_SQL, dquery);
    return 1;
}