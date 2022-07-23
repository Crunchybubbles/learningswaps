pragma solidity 0.7.6;
pragma abicoder v2;

interface Registry {
    struct PoolParams {
	uint256 A;
	uint256 future_A;
	uint256 fee;
	uint256 admin_fee;
	uint256 future_fee;
	address future_owner;
	uint256 initial_A;
	uint256 initial_A_time;
	uint256 future_A_time;
    }
    function pool_count() external view returns(uint256);
    function pool_list(uint256 i) external view returns(address);
    function get_coins(address pool) external view returns(address[8] memory);
    function get_underlying_coins(address pool) external view returns(address[8] memory);
    function get_decimals(address pool) external view returns (uint256[8] memory);
    function get_underlying_decimals(address pool) external view returns (uint256[8] memory);
    function get_balances(address pool) external view returns(uint256[8] memory);
    function get_underlying_balances(address pool) external view returns(uint256[8] memory);
    function get_rates(address pool) external view returns(uint256[8] memory);
    function get_pool_name(address pool) external view returns(string memory);
    function is_meta(address pool) external view returns(bool);
    function get_n_coins(address pool) external view returns(uint256[2] memory);
    function get_parameters(address pool) external view returns(PoolParams memory);
}

interface CurvePool {
    function get_dy(int128 i, int128 j, uint256 dx) external view returns (uint256);
}

contract curveData {

    function test_dy(int128 i, int128 j, uint256 dx, address pool) external view returns (uint256) {
	return CurvePool(pool).get_dy(i,j,dx);
    }
    
    struct Data {
	address pool;
	address[8] coins;
	address[8] underlying_coins;
	uint256[8] decimals;
	uint256[8] underlying_decimals;
	uint256[8] balances;
	uint256[8] underlying_balances;
	uint256[8] rates;
	string name;
	bool meta;
	uint256[2] Ncoins;
	Registry.PoolParams params;
    }
	
    /* function get_info(address reg) public view returns (Data[] memory) { */
    /* 	Registry registry = Registry(reg); */
    /* 	uint256 count = registry.pool_count(); */
    /* 	Data[] memory result = new Data[](count); */
    /* 	for (uint256 i; i > count; i++) { */
    /* 	    address pool= registry.pool_list(i); */
    /* 	    address[8] memory coins = registry.get_coins(pool); */
    /* 	    address[8] memory underlying_coins = registry.get_underlying_coins(pool); */
    /* 	    uint256[8] memory decimals = registry.get_decimals(pool); */
    /* 	    uint256[8] memory underlying_decimals = registry.get_underlying_decimals(pool); */
    /* 	    uint256[8] memory balances = registry.get_balances(pool); */
    /* 	    uint256[8] memory underlying_balances = registry.get_underlying_balances(pool); */
    /* 	    uint256[8] memory rates = registry.get_rates(pool); */
    /* 	    string memory name = registry.get_pool_name(pool); */
    /* 	    bool meta = registry.is_meta(pool); */

    /* 	    Data memory data = Data(pool, coins, underlying_coins, decimals, underlying_decimals, balances, underlying_balances, rates, name, meta); */
    /* 	    result[i] = data; */
	    
    /* 	} */

    /* 	return result; */
    /* } */

   	
    function pool_info(address reg, address pool) public view returns (Data memory) {
	Registry registry = Registry(reg);

	Data memory result = Data({
	    pool: pool,
	    coins: registry.get_coins(pool),
	    underlying_coins: registry.get_underlying_coins(pool),
	    decimals: registry.get_decimals(pool),
	    underlying_decimals: registry.get_underlying_decimals(pool),
	    balances: registry.get_balances(pool),
	    underlying_balances: registry.get_underlying_balances(pool),
	    rates: registry.get_rates(pool),
	    name: registry.get_pool_name(pool),
	    meta: registry.is_meta(pool),
	    Ncoins: registry.get_n_coins(pool),
	    params: registry.get_parameters(pool)
	    });
	    
	return result;
    }

    /* function infoo(address registry) public view returns (Data[] memory result) { */
    /* 	uint256 count = Registry(registry).pool_count(); */
    /* 	Data[] memory result = new Data[](count); */
    /* 	for (uint256 i; i < count; i++) { */
    /* 	    address pool = Registry(registry).pool_list(i); */
    /* 	    result[i] = pool_info(registry, pool); */
    /* 	} */
    /* } */


}
