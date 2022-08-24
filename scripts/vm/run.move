script {
use 0x3::Vm;
use std::signer;

fun run(account: signer) {
    let res = Vm::run(signer::address_of(&account), x"00");
    let _ = res;
}
}