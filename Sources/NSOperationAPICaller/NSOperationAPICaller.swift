

import Foundation
import Moya

public class NSOperationAPICaller<Target: TargetType, RESPONSE>: AsyncOperation where RESPONSE : Decodable {
    public var responseBlock: ((Result<RESPONSE, Error>) -> Void )?
    private(set) var results:Result<RESPONSE, Error>? {
        didSet{
            guard let result = results else { return }
            self.responseBlock?(result)
            self.finish()
        }
    }
    public var dependencyTarget:( (Result<RESPONSE, Error>) -> (Target) )?
    
    private let moyaprovider: MoyaProvider<Target>
    fileprivate var apitarget: Target?
    private var apiTask: Cancellable?
    public override func cancel() {
        self.results = .failure(APICallCancelledError())
        self.apiTask?.cancel()
        super.cancel()
    }
    public init(target: Target?, shouldRunAutomatically: Bool = true, priority: Operation.QueuePriority = .low) {
        self.apitarget = target
        self.moyaprovider = MoyaProvider<Target>()
        super.init()
        self.queuePriority = priority
        if shouldRunAutomatically {
            APICallQueue.shared.addOperation(self)
        }
    }
    public override func main() {
        guard let apitarget = self.apitarget else { return }
        if isCancelled { return }
        
        apiTask = moyaprovider.request(apitarget, completion: {[weak self] response in
            switch response{
            case .success(let responseData):
                do{
                    let str = try responseData.mapString()
                    print(str)
                    let codableData = try JSONDecoder().decode(RESPONSE.self, from: responseData.data)
                    print(codableData)
                    self?.results = .success(codableData)
                }
                catch let jsonParsingError {
                    print(jsonParsingError)
                    self?.results = .failure(jsonParsingError)
                }
            case .failure(let moyaerror):
                self?.results = .failure(moyaerror)
            }
        })
    }
}

