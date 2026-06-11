// Copyright © FullStackShack. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.

enum Player { x, o }

extension PlayerX on Player {
  Player get opponent => this == Player.x ? Player.o : Player.x;
  String get label => name.toUpperCase();
}
