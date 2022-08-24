script {
use 0x3::Vm;
fun publish(account: signer) {
    /*
    push1 01
    push2 0002
    add
    caller
    add
    return
    */
    Vm::publish(&account, x"6001610002013301f3");
}
}