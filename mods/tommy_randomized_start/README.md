# [WIP]随机开局 Randomized Start

随机放置所有初始曲部的地图位置，使得每一次新游戏都完全不一样，每次开新周目都不用面对一模一样的初始场景。

目前该MOD只会影响在野外的曲部，在据点的曲部不会影响。玩家和AI曲部都会有效。

randomized position for all military forces in wild (outside the settlement) in the initial map, in order to make campaign strategic situation different every new game. Both PLAYER and AI effects.

This mod doesn't need any translation in the game, because the lua script never change the text data. ALL LANGUAGE SUITABLE.

[img]https://i.imgur.com/fVVaDCS.gif[/img]

随机放置规则：
1) 已有领土的阵营，会在已拥有领土地区和初始地区随机选择位置放置曲部
2) 汉王朝阵营，会按照曲部所在初始位置所在的区域随机选择位置（避免过于混乱）
3) 无初始领土的阵营(例如郑酱)会在全地图中随机选择一个位置，如果初始位置废弃会自动设置给该阵营
4) 对于190年刘备，194年孙策，会按照初始位置所在区域以及临近区域随机选择一个位置
5) 如果找不到合适的随机位置会自动使用默认位置

Reposition Rules:
1) For faction OWNS INITIAL REGIONS, random choose positions in the own initial territories and its adjacent territories 
2) For HAN EMPIRE ROYAL faction, each military forces random choose positions from its located initial territory, (prevent randomize make too many mass, because Han empire has too many initial territories)
3) For faction OWNS NO REGION (such as ZHANG JIANG), random choose positions in the whole map
4) For LIU BEI in 190, SUN CE in 194 random choose positions from its located initial territory and adjacent territories.(because their initial mission target needs)
5) IF the script of this mod didn't find a suitable position, military force will stay in the default position.

已实现功能:
1) 随机初始位置生成，并放置曲部位置
2) 初始镜头会自动移动到主要曲部中

Features:
1) random position for all military forces in wild.
2) initial camera will auto locate at the primary military force which randomized.

---- 2020.3.24 更新 ----
- 优化了曲部随机位置经常会重叠的问题，会稍微增加初始化的时间，现在位置会更加随机了
- 增加功能无初始领土的阵营(规则3)随机到的初始位置会自动给该阵营，避免开局无事可做
- 增加190年刘备，194年孙策，会按照初始位置所在区域以及临近区域随机选择一个位置（跟他们的任务有关）

- Optimized the issue that the random positions of military forces often overlap. It will slightly increase the initialization time. Now the positions will be more random.
- For faction owns NO territories(in rules 3), if the region of random initial position was abandoned(not capture by other faction), this region will be automatically given to the faction, avoiding player can do nothing at the start of game.
- add rules for LIU BEI in 190, SUN CE in 194
----

技术上来说，这个MOD，兼容所有DLC，以及所有其他 !!非通过CA初始事件!! 修改初始位置的MOD

Technically, this MOD is compatible with all DLC, and other MOD which not chaning the initial position by CA official lua initial events.

本mod还在开发中，更多功能后续待补充，有问题欢迎在评论区反馈...

This mod is still work in progress, more features may implement in the future, welcome discuss and report issues in the comments.
