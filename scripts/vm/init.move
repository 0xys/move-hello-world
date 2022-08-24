script {
use 0x3::Vm;
fun init(account: signer) {
    Vm::init(&account)
}
}