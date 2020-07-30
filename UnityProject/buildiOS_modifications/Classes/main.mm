+ (UnityFramework*)loadUnity
{
    UnityFramework* ufw = [UnityFramework getInstance];
    if (![ufw appController])
    {
        // unity is not initialized
        //[ufw setExecuteHeader: &_mh_execute_header];
    }

    [ufw setDataBundleId: "com.unity3d.framework"];
    
    return ufw;
}


- (char**)getArgumentArray
{
    NSArray* args = [[NSProcessInfo processInfo]arguments];

    unsigned count = [args count];
    char** array = (char **)malloc((count+ 1) * sizeof(char*));

    for (unsigned i = 0; i< count; i++)
    {
        array[i] = strdup([[args objectAtIndex:i] UTF8String]);
    }
    array[count] = NULL;
    return array;
}

- (unsigned)getArgumentCount
{
    NSArray* args = [[NSProcessInfo processInfo]arguments];

    unsigned count = [args count];
    return count;
}

- (void)freeArray:(char **)array
{
    if (array != NULL)
    {
        for (unsigned index = 0; array[index] != NULL; index++)
        {
            free(array[index]);
        }
        free(array);
    }
}

- (void)runEmbedded
{
    char** argv = [self getArgumentArray];
    unsigned argc = [self getArgumentCount];
    NSDictionary* appLaunchOpts = [[NSDictionary alloc] init];
    
    if (self->runCount)
    {
        // initialize from partial unload ( sceneLessMode & onPause )
        UnityLoadApplicationFromSceneLessState();
        [self pause: false];
        [self showUnityWindow];
    }
    else
    {
        // full initialization from ground up
        [self frameworkWarmup: argc argv: argv];

        id app = [UIApplication sharedApplication];

        id appCtrl = [[NSClassFromString([NSString stringWithUTF8String: AppControllerClassName]) alloc] init];
        [appCtrl application: app didFinishLaunchingWithOptions: appLaunchOpts];

        [appCtrl applicationWillEnterForeground: app];
        [appCtrl applicationDidBecomeActive: app];
    }

    self->runCount += 1;
}

//this method already exists, just add the difference
- (void)unloadApplication
{
    freeArray:([self getArgumentArray]); //added line of code
    UnityUnloadApplication();
}