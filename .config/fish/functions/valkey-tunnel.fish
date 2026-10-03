function valkey-tunnel
    # 1. Fallback to default namespace if none is provided
    set -l NAMESPACE "nhn-valkey-testnexus"
    if test (count $argv) -gt 0
        set NAMESPACE $argv[1]
    end

    echo "🌐 Environment context set to namespace: $NAMESPACE"

    # 2. Dynamic Service Name Discovery
    # Looks for any service labeled with 'valkey' or 'redis'
    echo "🔍 Discovering Valkey service routing..."
    set -l SVC_NAME (kubectl get svc -n $NAMESPACE -l "app.kubernetes.io/name=valkey" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
    
    # Fallback lookup selector if the first pattern returns nothing
    if test -z "$SVC_NAME"
        set SVC_NAME (kubectl get svc -n $NAMESPACE -l "app=valkey" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
    end
    
    # Check if a valid service was resolved
    if test -z "$SVC_NAME"
        echo "❌ Error: Could not locate a matching Valkey service via labels in '$NAMESPACE'."
        return 1
    end
    echo "📍 Found service resource: $SVC_NAME"

    # 3. Dynamic Credentials Discovery
    echo "🔑 Fetching system credentials..."
    set -l PASS (kubectl get secret valkey-secret -n $NAMESPACE -o json 2>/dev/null | jq -r '.data["valkey-password"]' | base64 -d 2>/dev/null)
    
    if test -z "$PASS"
        echo "❌ Error: Secret 'valkey-secret' not found in '$NAMESPACE'."
        return 1
    end

    # 4. Port Forwarding & Initialization
    echo "⚡ Spawning tunnel bridge via $SVC_NAME..."
    kubectl port-forward svc/$SVC_NAME 6379:6379 -n $NAMESPACE &
    set -l TUNNEL_PID $last_pid
    
    sleep 2 # Secure socket buffer allocation safety delay
    
    echo "🚀 Initializing iredis terminal overlay..."
    iredis -h 127.0.0.1 -p 6379 -a $PASS
    
    # 5. Clean Termination Handler
    kill $TUNNEL_PID 2>/dev/null
    echo "🔌 Tunnel closed safely."
end
