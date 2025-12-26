## Lack Of Disable Initializers Causing Template Contract Initialized By An Attacker
*Description*
The implementation (template contract) is used to provide logic functions for the user's EIP-1167-based clone instance.
However, the template does not either initialize or diasble initialize in the constructor.
Hence any user can call the template's initialize and set themselves as the owner.
As a result, the template itself will be improperly initialized as a logic provider for clones.
*Impact*
This vulnerability allows an attacker to initialize template contract, that means the template would be disabled by the attacker and all clones would be disabled too.
Apparently, impact is limited in this demo since there is no complex function, but is a standard hardening requirement for production.
*Recommendation*
Uses Initializable's _disableInitializers() in the template's constructor.