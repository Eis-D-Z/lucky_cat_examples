module swap_deployer::anime_swap_v1 {
    use sui::coin::{Self, Coin};
    use sui::tx_context::TxContext;


    public fun swap_coins_for_coins<X, Y>(coins_in: Coin<X>, ctx: &mut TxContext):Coin<Y> {
        coin::destroy_zero(coins_in);
        coin::zero<Y>(ctx)
    }
    
}