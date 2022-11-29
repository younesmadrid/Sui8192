module ethos::leaderboard_8192 {
    use sui::object::{Self, ID, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::table::{Self, Table};
    use sui::transfer;

    use ethos::game_8192::{Self, Game8192};

    const ENotALeader: u64 = 0;
    const ELowTile: u64 = 1;
    const ELowScore: u64 = 2;

    struct Leaderboard8192 has key, store {
        id: UID,
        top_game_id: ID,
        top_games: Table<ID, TopGame8192>,
        min_tile: u64,
        min_score: u64,
        game_count: u64,
        max_leaderboard_game_count: u64,
    }

    struct TopGame8192 has store, copy, drop {
        game_id: ID,
        leader_address: address,
        top_tile: u64,
        score: u64,
        next_game_id: ID,
        epoch: u64
    }

    fun init(ctx: &mut TxContext) {
        create(ctx);
    }

    // ENTRY FUNCTIONS //

    public entry fun create(ctx: &mut TxContext) {
        let leaderboard = Leaderboard8192 {
            id: object::new(ctx),
            top_game_id: object::id_from_address(tx_context::sender(ctx)),
            top_games: table::new<ID, TopGame8192>(ctx),
            min_tile: 0,
            min_score: 0,
            game_count: 0,
            max_leaderboard_game_count: 200,
        };

        transfer::share_object(leaderboard);
    }

    public entry fun submit_game(game: &mut Game8192, leaderboard: &mut Leaderboard8192, ctx: &mut TxContext) {
        let top_tile = *game_8192::top_tile(game);
        let score = *game_8192::score(game);
        assert!(top_tile >= leaderboard.min_tile, ELowTile);
        assert!(score >= leaderboard.min_score, ELowScore);

        let top_game_count = leaderboard.game_count;
        
        if (top_tile == leaderboard.min_tile && score == leaderboard.min_score) {
            assert!(top_game_count < leaderboard.max_leaderboard_game_count, ENotALeader);
        };

        let leader_address = *game_8192::player(game);
        let game_id = object::uid_to_inner(game_8192::id(game));
        // let leaderboard_id = object::uid_to_inner(&leaderboard.id);
        let score = *game_8192::score(game);
        let top_tile = *game_8192::top_tile(game);
        let epoch = tx_context::epoch(ctx);
        
        let top_game_count = table::length(&leaderboard.top_games);
        if (top_game_count == 0) {
            table::add(&mut leaderboard.top_games, game_id, TopGame8192 {
                game_id,
                leader_address,
                score,
                top_tile,
                next_game_id: game_id,
                epoch
            })
        };

        let mid_game_id = top_game_count / 2;
        let mig_game = 

        leaderboard.game_count = table::length(&leaderboard.top_games);
    }

    // PUBLIC ACCESSOR FUNCTIONS //

    public fun game_count(leaderboard: &Leaderboard8192): &u64 {
        &leaderboard.game_count
    }

    public fun top_games(leaderboard: &Leaderboard8192): &Table<ID, TopGame8192> {
        &leaderboard.top_games
    }

    public fun top_game_game_id(top_game: &TopGame8192): &ID {
        &top_game.game_id
    }

    public fun top_game_top_tile(top_game: &TopGame8192): &u64 {
        &top_game.top_tile
    }

    public fun top_game_score(top_game: &TopGame8192): &u64 {
        &top_game.score
    }

    public fun min_tile(leaderboard: &Leaderboard8192): &u64 {
        &leaderboard.min_tile
    }

    public fun min_score(leaderboard: &Leaderboard8192): &u64 {
        &leaderboard.min_score
    }

    

    // TEST FUNCTIONS //

    #[test_only]
    use sui::test_scenario::{Self, Scenario};

    #[test_only]
    public fun blank_leaderboard(scenario: &mut Scenario, max_leaderboard_game_count: u64, min_tile: u64, min_score: u64) {
        let ctx = test_scenario::ctx(scenario);
        let leaderboard = Leaderboard8192 {
            id: object::new(ctx),
            top_game_id: object::id_from_address(tx_context::sender(ctx)),
            top_games: table::new<ID, TopGame8192>(ctx),
            min_tile: min_tile,
            min_score: min_score,
            game_count: 0,
            max_leaderboard_game_count: max_leaderboard_game_count,
        };

        transfer::share_object(leaderboard)
    }
}