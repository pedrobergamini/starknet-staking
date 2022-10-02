from starkware.cairo.common.uint256 import Uint256

func uint256_ceil{range_check_ptr}(value: Uint256) -> (parsed_value: Uint256) {
    tempvar parsed_value: Uint256;
    %{
        import math
        ids.parsed_value.low = math.ceil(ids.value.low / 10 ** 18)
        ids.parsed_value.high = math.ceil(ids.value.high / 10 ** 18)
    %}
    [range_check_ptr] = parsed_value.low;
    [range_check_ptr + 1] = parsed_value.high;
    let range_check_ptr = range_check_ptr + 2;

    return (parsed_value,);
}
